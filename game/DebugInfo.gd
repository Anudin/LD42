extends Node

var visible = false
var timescale_modified = false

func _input(event):
	if event.is_action_pressed("debug_toggle"):
		visible = not visible
		
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("debug_timescale"):
		if not timescale_modified:
			timescale_modified = true
			Engine.time_scale *= .1
		else:
			timescale_modified = false
			Engine.time_scale *= 1/.1
		
		get_tree().set_input_as_handled()