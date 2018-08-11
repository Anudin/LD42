extends Node2D

onready var player = get_node("Player")

func _ready():
	DebugInfo.visible = true
	
	var width = ProjectSettings.get_setting("display/window/size/width")
	var height = ProjectSettings.get_setting("display/window/size/height")
	player.position = Vector2(width / 2, height / 2)
