extends Node2D

export(NodePath) var canvas_modulate

func _ready():
	canvas_modulate = get_node(canvas_modulate)

func _on_player_died():
	Engine.time_scale = 1
	AudioServer.set_bus_effect_enabled(0, 0, false)
	get_tree().paused = true
	visible = true
	
	get_node("../../CanvasModulate").color = Color(0.35,0.35,0.35,1)
	get_node("../LabelScore/AnimationPlayer").play("expand_score")

func _input(event):
	if visible and event.is_action_pressed("restart"):
		get_node("../LabelScore/AnimationPlayer").play("reset_score_font")
		yield(get_node("../LabelScore/AnimationPlayer"), "animation_finished")
	
		get_tree().paused = false
		get_tree().change_scene("res://Main.tscn")