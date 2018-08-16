extends Node2D

export(PackedScene) var tscn_next

func _input(event):
	if event.is_pressed():
		get_tree().set_input_as_handled()
		get_tree().change_scene_to(tscn_next)

func _ready():
	# Emit particles offscreen to precompile shaders
	$RocketExplosion.emitting = true
