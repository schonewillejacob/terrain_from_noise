extends Node3D
# creates UV map for noise texture
# orchestrates vertex mapping on QuadMesh grid



@export var noise_texture_height = 128
@export var noise_texture_width = 128
@export var quadmesh_grid_side_length = 2
var quadmesh_size : Vector2
var height_map : Image

@onready var node_chunk_collection = $Landscape
@onready var node_camera = $Camera3D
@onready var node_noise_preview = $UI/NoisePreview



# VIRTUALS ####################################################
func _ready() -> void:
	# generate noise UV
	height_map = create_height_map()
	
	# use a two-row approach to set vertex heights.
	#	the length of these row should be the grid side-length + 1
	var _vertex_row_even = []
	var _vertex_row_odd = []
	
	# dynamically add, map, and adjust vertex of QuadMesh grid
	for _x in quadmesh_grid_side_length:
		for _z in quadmesh_grid_side_length:
			print("QuadMesh %s, %s. Raising by Vertex matrix: <placeholder>" % [_x, _z])
			
	
	# set noise preview
	node_noise_preview.texture = ImageTexture.create_from_image(height_map)



# HELPERS #####################################################
func create_height_map() -> Image:
	# goal: long, thin cells.
	var _noise = FastNoiseLite.new()
	randomize()
	_noise.seed = randf() * 10_000_000 # set seed to a random integer from 0 - 9,999,999
	
	# NOISE CONFIGS
	_noise.cellular_distance_function = 2
	
	_noise.fractal_type = 3
	_noise.fractal_gain = 3
	_noise.fractal_lacunarity = 1
	_noise.fractal_gain = .005
	
	_noise.fractal_ping_pong_strength = 16
	# /NOISE CONFIGS
	
	var _noise_image = _noise.get_image(noise_texture_height,noise_texture_width) # no point in this being seamless, as the heightmap won't be tiled.
	
	return _noise_image

func set_row_from_heightmap():
	# get seed
	pass
