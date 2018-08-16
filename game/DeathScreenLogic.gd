extends Node2D

# TODO Refactor into seperate component

onready var canvas_modulate = get_tree().current_scene.get_node("CanvasModulate")
var animator_score

func _ready():
	animator_score = get_node("../LabelScore/AnimationPlayer")

func _on_player_died():
	Engine.time_scale = 1
	AudioServer.set_bus_effect_enabled(0, 0, false)
	get_tree().paused = true
	visible = true
	
	canvas_modulate.color = Color(0.35, 0.35, 0.35)
	animator_score.play("expand_score")

func _input(event):
	if visible and event.is_action_pressed("restart"):
		animator_score.play("reset_score_font")
		yield(animator_score, "animation_finished")
	
		get_tree().paused = false
		get_tree().change_scene_to(load("res://Main.tscn"))