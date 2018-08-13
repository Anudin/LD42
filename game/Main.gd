extends Node2D

# TODO FIX MULTIPLE ROCKETS SPAWNING ON SAME SPAWN

var width = ProjectSettings.get_setting("display/window/size/width")
var height = ProjectSettings.get_setting("display/window/size/height")
var center = Vector2(width / 2, height / 2)

onready var player = get_node("Player")
onready var label_score = get_node("HUD/Score")
onready var label_wave = get_node("HUD/Wave")

export var shrinking_rate = 5
export var rocket_rate = .25
export var explosion_radius = 32

var playarea_radius
var playarea_initial_radius
var playarea_min_radius

var timer_rocket_spawn
var tween_expand
var expanding = false

const SCORE_BONUS_KILL = 25

var score = 0
var wave = 0
var rocket_count
var time_bonus_factor = 1

func load_level_data():
	playarea_min_radius = level_data[wave]["min_radius"]
	rocket_count = level_data[wave]["rocket_count"]
	explosion_radius = level_data[wave]["rocket_radius"]
	
	print(playarea_min_radius)

func _on_rocket_killed():
	score += (SCORE_BONUS_KILL / 2)

func _ready():
	randomize()
	DebugInfo.visible = true
	
	player.connect("player_died", get_node("HUD/ScoreLogic"), "_on_player_died")
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
	
	load_level_data()

func expand_completed(object, key):
	expanding = false
	
func _physics_process(delta):
	if center.distance_to(player.position) > playarea_radius:
		player.acceleration = Vector2(0,0)
		player.velocity = (center - player.position).normalized() * player.velocity.length()

func timeout_timer_rocket_spawn():
	if get_tree().get_nodes_in_group("rockets").size() < rocket_count:
		var firebases = get_node("Firebases").get_children()
		
		while not firebases[randi() % firebases.size()].spawn_rocket(explosion_radius):
			pass

func _process(delta):
	score += delta * time_bonus_factor
	label_score.text = str(int(score))
	
	if not expanding and playarea_radius < playarea_min_radius:
		expanding = true
		
		if wave < level_data.size() - 1:
			wave += 1
			label_wave.text = str(wave + 1)
			get_node("AnimationPlayer").play("next_wave")
			
			time_bonus_factor += 1
			load_level_data()
		else:
			label_wave.text = "EXTRA"
		
		tween_expand.remove_all()
		tween_expand.interpolate_property(self,
			NodePath("playarea_radius"),
			playarea_radius,
			playarea_initial_radius, 
			.5, Tween.TRANS_EXPO, Tween.EASE_IN, 0)
		tween_expand.start()
	elif not expanding:
		playarea_radius -= delta * shrinking_rate
	
	update()

func _draw():
	draw_rect(Rect2(Vector2(0,0), Vector2(width, height)), Color("151515"), true)
	draw_circle(Vector2(width / 2, height / 2), playarea_radius, Color("252525"))

var level_data = [
	{
		"min_radius": 300,
		"rocket_rate": 1,
		"rocket_count": 4,
		"rocket_speed": 30,
		"rocket_radius": 16
	},
	{
		"min_radius": 200,
		"rocket_rate": 1,
		"rocket_count": 4,
		"rocket_speed": 30,
		"rocket_radius": 32
	},
	{
		"min_radius": 100,
		"rocket_rate": 1,
		"rocket_count": 4,
		"rocket_speed": 30,
		"rocket_radius": 48
	}
]