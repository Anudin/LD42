extends Node2D

var width = ProjectSettings.get_setting("display/window/size/width")
var height = ProjectSettings.get_setting("display/window/size/height")

var tscn_rocket = preload("res://Rocket/Rocket.tscn")

onready var player = get_node("Player")

export var explosion_radius = 32

func _ready():
	DebugInfo.visible = true
	
	player.position = Vector2(width / 2, height / 2)

func _process(delta):
	if get_tree().get_nodes_in_group("rockets").size() == 0:
		add_rocket(Vector2(0,0))
		add_rocket(Vector2(width,0))

func add_rocket(position):
	var rocket = tscn_rocket.instance()
	rocket.init(32)
	rocket.position = position
	add_child(rocket)