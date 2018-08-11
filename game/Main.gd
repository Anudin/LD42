extends Node2D

var width = ProjectSettings.get_setting("display/window/size/width")
var height = ProjectSettings.get_setting("display/window/size/height")

var tscn_rocket = preload("res://Rocket/Rocket.tscn")

onready var player = get_node("Player")

export var explosion_radius = 32

export var shrinking_rate = 2
var playarea_radius

func _ready():
	DebugInfo.visible = true
	
	player.position = Vector2(width / 2, height / 2)
	playarea_radius = height / 2

func _process(delta):
	playarea_radius -= delta * shrinking_rate
	update()
	
	if get_tree().get_nodes_in_group("rockets").size() == 0:
		add_rocket(Vector2(0,0))
		add_rocket(Vector2(width,0))

func add_rocket(position):
	var rocket = tscn_rocket.instance()
	rocket.init(32)
	rocket.position = position
	add_child(rocket)

func _draw():
	draw_circle(Vector2(width / 2, height / 2), playarea_radius, Color("333333"))