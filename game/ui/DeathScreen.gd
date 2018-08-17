extends Node2D

signal change_visibility

onready var canvas_modulate = owner.get_node("CanvasModulate")
onready var animator_score = get_node("../LabelScore/AnimationPlayer")

func _ready():
	pass

func _on_player_died():
	visible = true
	emit_signal("change_visibility", true)
	
	animator_score.play("expand_score")
	canvas_modulate.color = Color(0.35, 0.35, 0.35)
	
	Engine.time_scale = 1
	AudioServer.set_bus_effect_enabled(0, 0, false)
	get_tree().paused = true

func _input(event):
	if visible and event.is_action_pressed("restart"):
		# We animate the font RESOURCE and therefore need to reset it
		animator_score.play("reset_score_font")
		yield(animator_score, "animation_finished")
	
		get_tree().paused = false
		get_tree().change_scene_to(load("res://Main.tscn"))
		emit_signal("change_visibility", false)