extends Node2D

func _input(event):
	if event.is_pressed():
		get_tree().set_input_as_handled()
		get_tree().change_scene("res://Main.tscn")
