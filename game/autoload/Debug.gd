extends Node

var visible = false

func _input(event):
	if event.is_action_pressed("debug_toggle"):
		visible = !visible
		get_tree().set_input_as_handled()
