extends Node3D
# creates UV map for noise texture
# orchestrates vertex mapping on QuadMesh grid

var uv_map : FastNoiseLite

func _ready() -> void:
	var uv_map_image = FastNoiseLite.new()
	uv_map.cellular_distance_function = FastNoiseLite.DISTANCE_EUCLIDEAN_SQUARED
	uv_map
	
	
	pass
