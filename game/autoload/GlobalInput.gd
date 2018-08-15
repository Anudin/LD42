extends Node

func _input(event):
	var input_handled = true
	
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	elif event.is_action_pressed("mute_audio"):
		AudioServer.set_bus_mute(0, !AudioServer.is_bus_mute(0))
	else:
		input_handled = false
	
	if input_handled:
		get_tree().set_input_as_handled()
