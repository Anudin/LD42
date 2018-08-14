extends Node

var visible = false
var timescale_modified = false

var muted = false
var initial_db

func _ready():
	OS.window_fullscreen = true
	
	initial_db = AudioServer.get_bus_volume_db(0)

func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	elif event.is_action_pressed("mute_audio"):
		muted = !muted
		
		if muted:
			AudioServer.set_bus_volume_db(0, -100)
		else:
			AudioServer.set_bus_volume_db(0, initial_db)
	
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