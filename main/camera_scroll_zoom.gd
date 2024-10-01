extends Camera3D

var SCROLL_FACTOR = Vector3(0,1,1)
var SHIFT_FACTOR = 5.0
var rotation_flag = true
var shift_flag = false
var zoom_flag = false
var rotation_scale = 0.25

var PERSPECTIVE_SCALES = {"SMALL":Vector3(0,0,0), "LARGE":Vector3(128,0,128)}
@onready var node_parent = $".."

# VIRTUALS ####################################################
func _ready() -> void:
	# this just puts the starting position in a pre-determined place.
	node_parent.position = PERSPECTIVE_SCALES["LARGE"] 
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Called when the node enters the scene tree for the first time.
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		# flags and orthogonal view swap
		if event.is_action_pressed("ui_accept"):
			zoom_flag = true
		if event.is_action_released("ui_accept"):
			zoom_flag = false
		if event.is_action_pressed("ui_down"):
			projection = PROJECTION_ORTHOGONAL
			rotation_degrees.x = -90
			rotation_flag = false
		if event.is_action_released("ui_down"):
			projection = PROJECTION_PERSPECTIVE
			rotation_degrees.x = -45
			rotation_flag = true
	
	if event.is_action("mouse_translate"):
		shift_flag = true
	if event.is_action_released("mouse_translate"):
		shift_flag = false
			
	
	if event is InputEventMouseButton:
		# zoom and fast zoom /w spacebar
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			position += SCROLL_FACTOR + (Vector3(0, SHIFT_FACTOR, SHIFT_FACTOR) * int(shift_flag))
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			position -= SCROLL_FACTOR + (Vector3(0, SHIFT_FACTOR, SHIFT_FACTOR) * int(shift_flag))
		# set translate camera flag
	
	# rotate or translate camera
	if shift_flag and event is InputEventMouseMotion:
		node_parent.position.x += event.relative.x
		node_parent.position.z += event.relative.y
	elif rotation_flag and event is InputEventMouseMotion:
		node_parent.rotation_degrees.y = clamp(node_parent.rotation_degrees.y + (event.relative.x) * rotation_scale, -45, 45)
	
