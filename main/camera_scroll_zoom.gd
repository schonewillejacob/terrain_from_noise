extends Camera3D

var scroll_factor = Vector3(0,5,5)

# Called when the node enters the scene tree for the first time.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			position += scroll_factor
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			position -= scroll_factor
