extends Node2D

func _ready():
	Engine.time_scale = 1

func _on_player_died():
	get_tree().paused = true
	visible = true
	get_node("../../CanvasModulate").color = Color(0.35,0.35,0.35,1)
	get_node("../Score/AnimationPlayer").play("expand_score")

func _input(event):
	if visible and event.is_action_pressed("restart"):
		get_node("../Score/AnimationPlayer").play("reset_score_font")
		yield(get_node("../Score/AnimationPlayer"), "animation_finished")
	
		get_tree().paused = false
		get_tree().change_scene("res://Main.tscn")