extends Node3D
# creates UV map for noise texture
# orchestrates vertex mapping on QuadMesh grid



@export var noise_texture_side_length = 128
@export var quadmesh_grid_side_length = 2
var quadmesh_size : Vector2
var height_map : Image

@onready var node_landscape = $Landscape
@onready var node_camera = $Camera3D
@onready var node_noise_preview = $UI/NoisePreview



# VIRTUALS ####################################################
func _ready() -> void:
	# testing purposes: create red gradient
	height_map = Image.create_empty(noise_texture_side_length,noise_texture_side_length, false, Image.FORMAT_RG8) # all white image for testing purposes
	for _x in noise_texture_side_length:
		for _y in noise_texture_side_length:
			var _target : float = float(_x) / float(noise_texture_side_length)
			height_map.set_pixel(_x,_y,Color(_target,0,0,1))
	
	# generate noise UV
	#height_map = create_height_map()
	
	# use a two-row approach to set vertex heights.
	#	the length of each row should be the grid side-length + 1
	#	keeping rows in memory saves computation time row-to-row
	#	having only two saves memory
	var _vertex_row_even = set_row_heights_from_heightmap(0)
	var _vertex_row_odd = []
	
	# dynamically add, map, and adjust vertex of QuadMesh grid
	for _z in quadmesh_grid_side_length:
		if(_z % 2 == 0):
			_vertex_row_odd = set_row_heights_from_heightmap(_z+1)
			add_landscape_quad_row(_vertex_row_even, _vertex_row_odd, _z)
		else:
			_vertex_row_even = set_row_heights_from_heightmap(_z+1)
			add_landscape_quad_row(_vertex_row_even, _vertex_row_odd, _z)
		
	
	# set noise preview
	node_noise_preview.texture = ImageTexture.create_from_image(height_map)



# HELPERS #####################################################
func create_height_map() -> Image:
	# goal: long, thin cells.
	var _noise = FastNoiseLite.new()
	#randomize()
	#_noise.seed = randf() * 10_000_000 # set seed to a random integer from 0 - 9,999,999
	
	# NOISE CONFIGS
	_noise.cellular_distance_function = 2
	
	_noise.fractal_type = 3
	_noise.fractal_gain = 3
	_noise.fractal_lacunarity = 1
	_noise.fractal_gain = .005
	
	_noise.fractal_ping_pong_strength = 16
	# /NOISE CONFIGS
	
	var _noise_image = _noise.get_image(noise_texture_side_length,noise_texture_side_length) # no point in this being seamless, as the heightmap won't be tiled.
	
	return _noise_image

func add_landscape_quad_row(top_row,bottom_row,z_grid_position) -> void:
	for _x in quadmesh_grid_side_length:
		var _land = MeshInstance3D.new()
		var _surface_tool = SurfaceTool.new()
		
		_surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		# vertex 0
		_surface_tool.set_uv( Vector2(0, 0) )
		_surface_tool.add_vertex( Vector3(0, 0, 0) ) 
		# vertex 1
		_surface_tool.set_uv( Vector2(1, 0) )
		_surface_tool.add_vertex( Vector3(1, 0, 0) ) 
		# vertex 2
		_surface_tool.set_uv( Vector2(1, 1) )
		_surface_tool.add_vertex( Vector3(1, 0, 1) ) 
		# vertex 3
		_surface_tool.set_uv( Vector2(0, 1) )
		_surface_tool.add_vertex( Vector3(0, 0, 1) ) 
		# make the fir_surface_tool triangle
		_surface_tool.add_index(0) 
		_surface_tool.add_index(1)
		_surface_tool.add_index(2)
		# make the second triangle
		_surface_tool.add_index(0) 
		_surface_tool.add_index(2)
		_surface_tool.add_index(3)
		
		_surface_tool.generate_normals() # normals point perpendicular up from each face
		var _mesh = _surface_tool.commit() # arranges mesh data structures into arrays for us
		
		_land.mesh = _mesh 
	
func set_row_heights_from_heightmap(pos_z) -> Array:
	var _row_heights : Array
	for _position in (quadmesh_grid_side_length + 1):
		var _x_target = float(_position)/float(quadmesh_grid_side_length) * float(noise_texture_side_length)
		_row_heights.append(height_map.get_pixel(_x_target, pos_z).r) # returns a float of the pixel's red channel, from 0-1
		
	print(_row_heights)
	return _row_heights
