extends Node3D
# creates UV map for noise texture
# orchestrates vertex mapping on QuadMesh grid



@export var uv_height = 128
@export var uv_width = 128
@export var quadmesh_grid_x = 2
@export var quadmesh_grid_z = 2
var quadmesh_size : Vector2
var uv_map : Image

@onready var node_chunk_collection = $ChunkCollection
@onready var node_camera = $Camera3D
@onready var node_noise_preview = $UI/NoisePreview



# VIRTUALS ####################################################
func _ready() -> void:
	# Packs the chunk scene
	var _scene_chunk = load("res://landscape/chunk.tscn")
	
	# retrieve chunk scene size
	var _inst_size_chunk = _scene_chunk.instantiate()
	quadmesh_size = _inst_size_chunk.mesh.size
	_inst_size_chunk.queue_free()
	
	# geenerate noise UV
	uv_map = create_uv_map()
	
	# dynamically add, map, and adjust vertex of QuadMesh grid
	for _x in quadmesh_grid_x:
		for _z in quadmesh_grid_z:
			print("QuadMesh %s, %s" % [_x, _z])
			var _instance_chunk = _scene_chunk.instantiate()
			_instance_chunk.position = Vector3(_x*quadmesh_size.x, 0, _z*quadmesh_size.y)
			node_chunk_collection.add_child(_instance_chunk)
	
	# adjust camera position dynamically, position preview Sprite3D in view.
	var _camera_pos_x = (0.5 * quadmesh_size.x * quadmesh_grid_x) - (0.5 * quadmesh_size.x)
	var _camera_pos_y = node_camera.position.y
	var _camera_pos_z = quadmesh_size.y * quadmesh_grid_z
	node_camera.position = Vector3(_camera_pos_x, _camera_pos_y, _camera_pos_z)
	node_noise_preview.texture = ImageTexture.create_from_image(uv_map)



# HELPERS #####################################################
func create_uv_map() -> Image:
	# goal: long, thin cells.
	var _noise = FastNoiseLite.new()
	
	# NOISE CONFIGS
	_noise.cellular_distance_function = 2
	
	_noise.fractal_type = 3
	_noise.fractal_gain = 3
	_noise.fractal_lacunarity = 1
	_noise.fractal_gain = .005
	
	_noise.fractal_ping_pong_strength = 16
	# /NOISE CONFIGS
	
	var _noise_image = _noise.get_seamless_image(uv_height,uv_width)
	
	return _noise_image
