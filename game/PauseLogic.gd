extends Node2D

func _input(event):
	if event.is_action_pressed("pause"):
		if not visible:
			get_tree().paused = true
			visible = true
			get_node("../../CanvasModulate").color = Color(0.35,0.35,0.35)
		else:
			get_tree().paused = false
			visible = false
			get_node("../../CanvasModulate").color = Color(1,1,1)
	elif visible and event.is_action_pressed("exit"):
		get_tree().quit()