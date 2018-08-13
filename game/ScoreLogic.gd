extends Node2D

func _on_player_died():
	get_tree().paused = true
	visible = true
	get_node("../../CanvasModulate").color = Color(0.25,0.25,0.25,1)
	get_node("../Score/AnimationPlayer").play("expand_score")

func _input(event):
	if get_tree().paused and event.is_action_pressed("pause"):
		get_tree().paused = false
		get_tree().change_scene("res://Main.tscn")