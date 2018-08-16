extends Node2D

signal score_changed
signal wave_changed

# 1. Timer auf dem  SceneTree sind extrem gefährlich. Nur überlegt nutzen.
# One line timer sind trotzdem nützlich, allerdings mit connect

# 2. Niemals die Auflösung einer Kollision für eine andere Komponente übernehmen.

# 3. Engine.time_scale lieber multiplizieren statt absolut zu setzen, so kann an 
# mehreren Stellen manipuliert werden.

# 4. Gameplay code sollte IDR auf unhandled_input reagieren

# 5. Die meisten Komponenten benötigen eine State Machine. Im Todesfall bietet sich an:
# - CollisionShape deaktivieren
# - Status Flag setzen
#	- Alle Methoden sollten auf Status Flag reagieren
# - Nicht einfach Verhalten vorraus setzen, entsprechende Methoden / Signale aufrufen

# 6. Szenen, Nodes etc. so früh wie möglich / an einer Stelle laden
# Damit werden auch Fehler durch falsche Pfade möglicherweise sichtbar

# 7. Wie kann ich von externen Abhängigkeiten abstrahieren, vor allem auch "Main" Szene
# Und direkte Abhängigkeiten vom Aufbau der Szene?!

# 8. Hinzufügen und entfernen von Kindern immer mit deferred

# 9. Löschen von Elementen über SceneTree

# 10. Ändern von Szenen über SceneTree

# 11. Externe Szenen über export Variable, hält Refactoring stand
# Nodes immer be Instanzierung laden, damit Fehler früh auffallen
# Keine export variablen für in code instanzierte Elemente!

# 12. Shortcuts nutzen!

# 13. Tools für verwaiste Dateien und Referenzen nutzen

# 14. get_node can be replaced with $ ...

# 15. weakref für externe abhängigkeiten? 

# Signale über zentrales Node?! Autoload?!

# TODO FIX MULTIPLE ROCKETS SPAWNING ON SAME SPAWN

var width = ProjectSettings.get_setting("display/window/size/width")
var height = ProjectSettings.get_setting("display/window/size/height")
var center = Vector2(width / 2, height / 2)

onready var animator_canvas_modulate = get_node("CanvasModulate/AnimationPlayer")

onready var camera = get_node("Camera")
onready var player = get_node("Player")

export var shrinking_rate = 10
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
var rocket_speed
var rocket_count
var time_bonus_factor = 1

var tween_shake
var shaking = false

func _on_rocket_exploded(rocket):
	if rocket.get_ref() and not shaking:
		var goal = -(center - rocket.get_ref().position).normalized() * 10
		
		tween_shake.remove_all()
		tween_shake.interpolate_property(camera, "offset", 
			Vector2(0,0), goal, 
			.2, 
			Tween.TRANS_BOUNCE, Tween.EASE_IN)
		tween_shake.interpolate_property(camera, "offset", 
			goal, Vector2(0,0), 
			.2, 
			Tween.TRANS_BOUNCE, Tween.EASE_IN, .2)
		
		tween_shake.start()

func load_level_data():
	playarea_min_radius = level_data[wave]["min_radius"]
	rocket_speed = level_data[wave]["rocket_speed"]
	rocket_count = level_data[wave]["rocket_count"]
	explosion_radius = level_data[wave]["rocket_radius"]

func _on_rocket_killed():
	score += (SCORE_BONUS_KILL / 2)
	emit_signal("score_changed", score, true)
	
	shaking = true
	
	var r_ang = deg2rad(randi() % 360)
	var goal = Vector2(cos(r_ang), sin(r_ang)) * 50
	
	tween_shake.remove_all()
	tween_shake.interpolate_property(camera, "offset", 
		Vector2(0,0), goal,
		.4, 
		Tween.TRANS_BOUNCE, Tween.EASE_IN)
	tween_shake.interpolate_property(camera, "offset", 
		goal, Vector2(0,0), 
		.4, 
		Tween.TRANS_BOUNCE, Tween.EASE_IN, .4)
	
	tween_shake.start()
	
	yield(tween_shake, "tween_completed")
	shaking = false

func _ready():
	randomize()
	
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
	
	tween_shake = Tween.new()
	add_child(tween_shake)
	
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
		
		while not firebases[randi() % firebases.size()].spawn_rocket(rocket_speed, explosion_radius):
			pass

func _process(delta):
	score += delta * time_bonus_factor
	emit_signal("score_changed", score)
	
	if not expanding and playarea_radius < playarea_min_radius:
		expanding = true
		
		if wave < level_data.size() - 1:
			wave += 1
			animator_canvas_modulate.play("next_wave")
			emit_signal("wave_changed", wave)
			
			time_bonus_factor += .15
			load_level_data()
		else:
			emit_signal("wave_changed", -1)
		
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
	# Gen
	{
		"min_radius": 250,
		"rocket_rate": 1,
		"rocket_count": 3,
		"rocket_speed": 30,
		"rocket_radius": 16
	},
	{
		"min_radius": 200,
		"rocket_rate": 1,
		"rocket_count": 4,
		"rocket_speed": 30,
		"rocket_radius": 16
	},
	{
		"min_radius": 150,
		"rocket_rate": 1,
		"rocket_count": 5,
		"rocket_speed": 30,
		"rocket_radius": 16
	},
	# Gen
	{
		"min_radius": 250,
		"rocket_rate": 1,
		"rocket_count": 4,
		"rocket_speed": 30,
		"rocket_radius": 24
	},
	{
		"min_radius": 200,
		"rocket_rate": 1,
		"rocket_count": 5,
		"rocket_speed": 30,
		"rocket_radius": 24
	},
	{
		"min_radius": 150,
		"rocket_rate": 1,
		"rocket_count": 5,
		"rocket_speed": 30,
		"rocket_radius": 24
	},
	# Gen
	{
		"min_radius": 250,
		"rocket_rate": 1,
		"rocket_count": 5,
		"rocket_speed": 30,
		"rocket_radius": 24
	},
	{
		"min_radius": 200,
		"rocket_rate": 1,
		"rocket_count": 6,
		"rocket_speed": 30,
		"rocket_radius": 24
	},
	{
		"min_radius": 150,
		"rocket_rate": 1,
		"rocket_count": 6,
		"rocket_speed": 30,
		"rocket_radius": 24
	},
	# Gen
	{
		"min_radius": 250,
		"rocket_rate": 1,
		"rocket_count": 6,
		"rocket_speed": 30,
		"rocket_radius": 32
	},
	{
		"min_radius": 200,
		"rocket_rate": 1,
		"rocket_count": 6,
		"rocket_speed": 30,
		"rocket_radius": 32
	},
	{
		"min_radius": 150,
		"rocket_rate": 1,
		"rocket_count": 6,
		"rocket_speed": 30,
		"rocket_radius": 32
	},
	# Gen
	{
		"min_radius": 250,
		"rocket_rate": 1,
		"rocket_count": 6,
		"rocket_speed": 30,
		"rocket_radius": 48
	},
	{
		"min_radius": 200,
		"rocket_rate": 1,
		"rocket_count": 6,
		"rocket_speed": 30,
		"rocket_radius": 48
	},
	{
		"min_radius": 150,
		"rocket_rate": 1,
		"rocket_count": 6,
		"rocket_speed": 30,
		"rocket_radius": 48
	},
	# Gen
	{
		"min_radius": 250,
		"rocket_rate": 1,
		"rocket_count": 6,
		"rocket_speed": 35,
		"rocket_radius": 48
	},
	{
		"min_radius": 200,
		"rocket_rate": 1,
		"rocket_count": 6,
		"rocket_speed": 35,
		"rocket_radius": 48
	},
	{
		"min_radius": 150,
		"rocket_rate": 1,
		"rocket_count": 6,
		"rocket_speed": 35,
		"rocket_radius": 48
	},
	# Gen
	{
		"min_radius": 250,
		"rocket_rate": 1,
		"rocket_count": 6,
		"rocket_speed": 40,
		"rocket_radius": 48
	},
	{
		"min_radius": 200,
		"rocket_rate": 1,
		"rocket_count": 6,
		"rocket_speed": 40,
		"rocket_radius": 48
	},
	{
		"min_radius": 150,
		"rocket_rate": 1,
		"rocket_count": 6,
		"rocket_speed": 40,
		"rocket_radius": 48
	},
	# Gen
	{
		"min_radius": 250,
		"rocket_rate": 1,
		"rocket_count": 7,
		"rocket_speed": 40,
		"rocket_radius": 48
	},
	{
		"min_radius": 200,
		"rocket_rate": 1,
		"rocket_count": 7,
		"rocket_speed": 40,
		"rocket_radius": 48
	},
	{
		"min_radius": 150,
		"rocket_rate": 1,
		"rocket_count": 7,
		"rocket_speed": 40,
		"rocket_radius": 48
	},
	# Gen
	{
		"min_radius": 250,
		"rocket_rate": 1,
		"rocket_count": 8,
		"rocket_speed": 40,
		"rocket_radius": 48
	},
	{
		"min_radius": 200,
		"rocket_rate": 1,
		"rocket_count": 8,
		"rocket_speed": 40,
		"rocket_radius": 48
	},
	{
		"min_radius": 150,
		"rocket_rate": 1,
		"rocket_count": 8,
		"rocket_speed": 40,
		"rocket_radius": 48
	}
]