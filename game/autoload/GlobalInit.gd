extends Node

func _ready():
	# Fullscreen toggle doesn't work from code when fullscreen is set in project settings
	OS.window_fullscreen = true

	if OS.is_debug_build():
		OS.window_fullscreen = false
		AudioServer.set_bus_mute(0, true)
