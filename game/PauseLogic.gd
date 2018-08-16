extends Node2D

export(NodePath) var canvas_modulate

func _ready():
	canvas_modulate = get_node(canvas_modulate)

func _input(event):
	if event.is_action_pressed("toggle_pause"):
		get_tree().paused = !get_tree().paused
		visible = !visible
		
		if visible:
			canvas_modulate.color = Color(0.35, 0.35, 0.35)
		else:
			canvas_modulate.color = Color(1, 1, 1)
	elif visible and event.is_action_pressed("exit"):
		if OS.get_name() != "HTML5":
			get_tree().quit()