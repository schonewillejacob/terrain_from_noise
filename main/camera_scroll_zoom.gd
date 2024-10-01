extends Camera3D

var SCROLL_FACTOR = Vector3(0,1,1)
var SHIFT_FACTOR = 5.0
var shift_flag = false

var PERSPECTIVE_SCALES = {"SMALL":Vector3(0,0,0), "LARGE":Vector3(128,0,128)}
@onready var node_animation_player = $"../AnimationPlayer"

# VIRTUALS ####################################################
func _ready() -> void:
	pass
	#position = PERSPECTIVE_SCALES["SMALL"]

# Called when the node enters the scene tree for the first time.
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("ui_accept"):
			shift_flag = true
		if event.is_action_released("ui_accept"):
			shift_flag = false
		if event.is_action_pressed("ui_down"):
			projection = 1 # orthoganal
			rotation_degrees.x = -90
			node_animation_player.pause()
		if event.is_action_released("ui_down"):
			projection = 0 # perspective
			rotation_degrees.x = -45
			node_animation_player.play()
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			position += SCROLL_FACTOR + (Vector3(0, SHIFT_FACTOR, SHIFT_FACTOR) * int(shift_flag))
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			position -= SCROLL_FACTOR + (Vector3(0, SHIFT_FACTOR, SHIFT_FACTOR) * int(shift_flag))
