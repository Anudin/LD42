extends Node2D

signal change_visibility

onready var canvas_modulate = owner.get_node("CanvasModulate")

func _ready():
	if OS.get_name() == "HTML5":
		$ExitHint.visible = false

func _input(event):
	if event.is_action_pressed("toggle_pause"):
		get_tree().paused = !get_tree().paused
		visible = !visible
		
		if visible:
			canvas_modulate.color = Color(0.35, 0.35, 0.35)
		else:
			canvas_modulate.color = Color(1, 1, 1)
	elif visible and event.is_action_pressed("exit") and \
	OS.get_name() != "HTML5":
		get_tree().quit()