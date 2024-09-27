extends Node3D
# creates UV map for noise texture
# orchestrates vertex mapping on QuadMesh grid



@export var noise_texture_side_length : int = 256
@export var quadmesh_grid_side_length : int = 256
var quadmesh_size : Vector2
var height_map : Image
var y_scale : float = 10.0

@onready var node_landscape = $Landscape
@onready var node_noise_preview = $UI/NoisePreview



# VIRTUALS ####################################################
func _ready() -> void:
	## testing purposes: create red gradient
	#height_map = Image.create_empty(noise_texture_side_length,noise_texture_side_length, false, Image.FORMAT_RG8) # all white image for testing purposes
	#for _x in noise_texture_side_length:
		#for _y in noise_texture_side_length:
			#var _target : float = float(_x) / float(noise_texture_side_length)
			#height_map.set_pixel(_x,_y,Color(_target,0,0,1))
	
	# generate noise UV
	height_map = create_height_map()
	
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
			add_landscape_quad_row(_vertex_row_odd, _vertex_row_even, _z)
		else:
			_vertex_row_even = set_row_heights_from_heightmap(_z+1)
			add_landscape_quad_row(_vertex_row_even, _vertex_row_odd, _z)
		
	
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
	
	_noise.fractal_ping_pong_strength = 2
	# /NOISE CONFIGS
	
	var _noise_image = _noise.get_image(noise_texture_side_length,noise_texture_side_length) # no point in this being seamless, as the heightmap won't be tiled.
	
	return _noise_image

func add_landscape_quad_row(top_row : Array, bottom_row : Array, z_grid_position : int) -> void:
	for _x in quadmesh_grid_side_length:
		var _land = MeshInstance3D.new()
		var _surface_tool = SurfaceTool.new()
		
		_surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		# vertex 0,0 = bottom-left
		_surface_tool.set_uv( Vector2(0, 0) )
		_surface_tool.add_vertex( Vector3(0, bottom_row[_x] * y_scale, 0) ) 
		# vertex 1,0 = bottom-right
		_surface_tool.set_uv( Vector2(1, 0) )
		_surface_tool.add_vertex( Vector3(1, bottom_row[_x+1] * y_scale, 0) ) 
		# vertex 1,1 = top-right
		_surface_tool.set_uv( Vector2(1, 1) )
		_surface_tool.add_vertex( Vector3(1, top_row[_x+1] * y_scale, 1) ) 
		# vertex 0,1 = top-left
		_surface_tool.set_uv( Vector2(0, 1) )
		_surface_tool.add_vertex( Vector3(0, top_row[_x] * y_scale, 1) ) 
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
		var _height_colour_material = StandardMaterial3D.new()
		_height_colour_material.albedo_color = Color(top_row[_x],.5,.6,1)
		
		_land.mesh.surface_set_material(0,_height_colour_material)
		_land.position = Vector3(_x,0,z_grid_position)
		
		node_landscape.add_child(_land)
	
func set_row_heights_from_heightmap(pos_z : int) -> Array:
	var _row_heights : Array
	for _x_position in (quadmesh_grid_side_length + 1):
		var _x_target = float(_x_position)/float(quadmesh_grid_side_length) * float(noise_texture_side_length)
		var _z_target = clamp(pos_z-1, 0, noise_texture_side_length-1)
		_x_target = clamp(_x_target-1,0,noise_texture_side_length-1)
		_row_heights.append(height_map.get_pixel(_x_target, _z_target).r) # returns a float of the pixel's red channel, from 0-1
		
	return _row_heights
