extends Node2D

var tscn_rocket = preload("res://Rocket/Rocket.tscn")

onready var player = get_node("Player")

func _ready():
	DebugInfo.visible = true
	
	var width = ProjectSettings.get_setting("display/window/size/width")
	var height = ProjectSettings.get_setting("display/window/size/height")
	player.position = Vector2(width / 2, height / 2)
	
	var rocket = tscn_rocket.instance()
	rocket.init(32)
	add_child(rocket)
