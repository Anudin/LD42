extends Node2D

var width = ProjectSettings.get_setting("display/window/size/width")
var height = ProjectSettings.get_setting("display/window/size/height")
var center = Vector2(width / 2, height / 2)

var tscn_rocket = preload("res://Rocket/Rocket.tscn")

onready var player = get_node("Player")

export var shrinking_rate = 20
export var rocket_rate = 1
export var explosion_radius = 32

var playarea_radius
var playarea_initial_radius
var playarea_min_radius = 100

var timer_rocket_spawn
var tween_expand
var expanding = false

func _ready():
	randomize()
	DebugInfo.visible = true
	
	player.position = Vector2(width / 2, height / 2)
	playarea_radius = height / 2
	playarea_initial_radius = playarea_radius
	
	timer_rocket_spawn = Timer.new()
	add_child(timer_rocket_spawn)
	timer_rocket_spawn.wait_time = rocket_rate
	timer_rocket_spawn.start()
	timer_rocket_spawn.connect("timeout", self, "timeout_timer_rocket_spawn")
	
	tween_expand = Tween.new()
	add_child(tween_expand)
	tween_expand.connect("tween_completed", self, "expand_completed")

func expand_completed(object, key):
	expanding = false
	
func _physics_process(delta):
	if center.distance_to(player.position) > playarea_radius:
		player.acceleration = Vector2(0,0)
		player.velocity = (center - player.position).normalized() * player.velocity.length()

func timeout_timer_rocket_spawn():
	if get_tree().get_nodes_in_group("rockets").size() < 4:
		var firebases = get_node("Firebases").get_children()
		add_rocket(firebases[randi() % firebases.size()].position)

func _process(delta):	
	if not expanding and  playarea_radius < playarea_min_radius:
		expanding = true
		
		tween_expand.remove_all()
		tween_expand.interpolate_property(self,
			NodePath("playarea_radius"),
			playarea_radius,
			playarea_initial_radius, 
			1, Tween.TRANS_EXPO, Tween.EASE_IN, 0)
		tween_expand.start()
	elif not expanding:
		playarea_radius -= delta * shrinking_rate
	
	update()
	
	if playarea_radius < playarea_min_radius:
		pass # TODO Next level?

func add_rocket(position):
	var rocket = tscn_rocket.instance()
	rocket.init(32)
	rocket.position = position
	add_child(rocket)

func _draw():
	draw_circle(Vector2(width / 2, height / 2), playarea_radius, Color("333333"))