extends Node3D
# creates UV map for noise texture
# orchestrates vertex mapping



@export var quadmesh_grid_side_length : int = 256
var quadmesh_size : Vector2
var height_map : Image
var y_scale : float = 2.0
var darkness_scale : float = 4.0

# the noise texture is set to always be a multiple of quadmesh_grid_side_length0,
#	to prevent floating point errors causing visual artefacts
var noise_texture_side_length : int = quadmesh_grid_side_length * 2
var landscape_material : StandardMaterial3D

@onready var node_landscape = $Landscape
@onready var node_noise_preview = $UI/NoisePreview



# VIRTUALS ####################################################
func _ready() -> void:
	landscape_material = StandardMaterial3D.new()
	landscape_material.vertex_color_use_as_albedo = true
	
	generate_terrain()



# HELPERS #####################################################
func add_landscape_quad_row(top_row : Array, bottom_row : Array, z_grid_position : int) -> void:
	var _land = MeshInstance3D.new()
	var _surface_tool = SurfaceTool.new()
	var _row_offset : float = float(z_grid_position) * float(quadmesh_grid_side_length)
	var _column_index : int = 0
	
	_surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for _x in quadmesh_grid_side_length:
		# as the colour approaches ~0.2, things just become white.
		#	this tweak both saves computation time and embellishes noise texture
		var darkened_colours_00 = bottom_row[_x] / darkness_scale
		var darkened_colours_10 = bottom_row[_x+1] / darkness_scale
		var darkened_colours_11 = top_row[_x+1] / darkness_scale
		var darkened_colours_01 = top_row[_x] / darkness_scale
		
		# vertex0 0,0 = bottom-left
		_surface_tool.set_uv( Vector2(0, 0) )
		_surface_tool.set_color(Color(darkened_colours_00,darkened_colours_00,darkened_colours_00,1))
		_surface_tool.add_vertex( Vector3(_x, bottom_row[_x] * y_scale, z_grid_position) ) 
		# vertex 1,0 = bottom-right
		_surface_tool.set_uv( Vector2(1, 0) )
		_surface_tool.set_color(Color(darkened_colours_10,darkened_colours_10,darkened_colours_10,1))
		_surface_tool.add_vertex( Vector3(_x+1, bottom_row[_x+1] * y_scale, z_grid_position) ) 
		# vertex 1,1 = top-right
		_surface_tool.set_uv( Vector2(1, 1) )
		_surface_tool.set_color(Color(darkened_colours_11,darkened_colours_11,darkened_colours_11,1))
		_surface_tool.add_vertex( Vector3(_x+1, top_row[_x+1] * y_scale, z_grid_position+1) ) 
		# vertex 0,1 = top-left
		_surface_tool.set_uv( Vector2(0, 1) )
		_surface_tool.set_color(Color(darkened_colours_01,darkened_colours_01,darkened_colours_01,1))
		_surface_tool.add_vertex( Vector3(_x, top_row[_x] * y_scale, z_grid_position+1) ) 
		
		_column_index += 4
		# first triangle
		_surface_tool.add_index(_column_index-4)
		_surface_tool.add_index(_column_index-3)
		_surface_tool.add_index(_column_index-2)
		# second triangle
		_surface_tool.add_index(_column_index-4)
		_surface_tool.add_index(_column_index-2)
		_surface_tool.add_index(_column_index-1)
	
	_surface_tool.generate_normals() # normals point perpendicular up from each face
	var _mesh = _surface_tool.commit() # arranges mesh data structures into arrays for us
	
	_land.mesh = _mesh
	_land.material_override = landscape_material
	
	node_landscape.add_child(_land)

func create_height_map() -> Image:
	# goal: long, thin cells.
	
	# randomized noise Image
	var _noise = FastNoiseLite.new()
	randomize()
	_noise.seed = randf() * 10_000_000 # set seed to a random integer from 0 - 9,999,999
	
	# NOISE CONFIGS
	_noise.cellular_distance_function = 2
	
	_noise.fractal_type = 3
	_noise.fractal_gain = 3
	_noise.fractal_lacunarity = 1
	_noise.fractal_gain = .005
	
	_noise.fractal_ping_pong_strength = 1
	# /NOISE CONFIGS
	
	var _noise_image = _noise.get_image(noise_texture_side_length,noise_texture_side_length) # no point in this being seamless, as the heightmap won't be tiled.
	
	return _noise_image

func generate_terrain() -> void:
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

func _on_generate():
	
	generate_terrain()

func set_row_heights_from_heightmap(pos_z : int) -> Array:
	var _row_heights : Array
	
	for _x_position in (quadmesh_grid_side_length + 1):
		var _x_target = float(_x_position)/float(quadmesh_grid_side_length) * float(noise_texture_side_length)
		_x_target = clamp(_x_target,0,noise_texture_side_length-1)
		
		var _z_target = float(pos_z)/float(quadmesh_grid_side_length) * float(noise_texture_side_length)
		_z_target = clamp(_z_target,0,noise_texture_side_length-1)
		
		_row_heights.append(height_map.get_pixel(_x_target, _z_target).r) # returns a float of the pixel's red channel, from 0-1
	
	return _row_heights
