extends MeshInstance3D
# displays heights
# provides simple mechanism for changing vertex heights.

@export var uv_height = 128
@export var uv_width = 128
var uv_map : Image

# VIRTUALS ####################################################
func _ready() -> void:
	uv_map = create_uv_map()
	set_quadmesh_vertex_heights(uv_map)

# HELPERS #####################################################
func set_quadmesh_vertex_heights(_uv_map : Image) -> void:
	
	pass

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
	
	var _noise_image = _noise.get_image(uv_height,uv_width)
	var _image = Image.create(uv_height,uv_width,false,Image.FORMAT_RGBA8)
	
	return _image
