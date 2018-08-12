extends Area2D

var tscn_counter = preload("res://Player/Counter.tscn")

onready var counter_timer = get_node("/root/Main/HUD/CounterTimer")

# TODO Make counters correct fleight paths

export var target_mode_length = 3
export var target_timescale = .1
# TODO Cone Ausrichtung korrigieren
export var target_cone_angle = 90
export var boost_length_sec = 1
export var boost_acceleration = 480
export var boost_speed = 720

const TARGET_ACTIVATION_RADIUS = 200
# TODO Rename TARGET_EXPLOSION_RADIUS, or even better move to Counter
const TARGET_VISIBLE_RADIUS = 60

var timer_doubleclick
var last_event
var timer_boost

var max_speed = 180
var max_acceleration = 120

var velocity = Vector2(0,0)
var acceleration = Vector2(0,0)

var target_mode = false
var target = null
var target_offset

const COUNTER_TIMER_ACTIVE_TIME = 2
const COUNTER_TIMER_FILL_TIME = 2
const COUNTER_TIMER_KILL_BONUS = 100

func _ready():
	target_cone_angle = deg2rad(target_cone_angle)
	
	timer_doubleclick = Timer.new()
	timer_doubleclick.wait_time = TimingConstants.TRESHOLD_DOUBLECLICK
	timer_doubleclick.one_shot = true
	add_child(timer_doubleclick)
	
	timer_boost = Timer.new()
	timer_boost.wait_time = boost_length_sec
	timer_boost.one_shot = true
	add_child(timer_boost)

func _unhandled_input(event):
	var movement_event_occured = true
	
	if event.action_match(last_event) and event.is_pressed() and not timer_doubleclick.is_stopped():
		timer_doubleclick.stop()
		register_doubleclick_input_event(event)
		return
	
	if event.is_action_pressed("player_up"):
		acceleration.y = -max_acceleration
	elif event.is_action_pressed("player_down"):
		acceleration.y = max_acceleration
	elif event.is_action_pressed("player_left"):
		acceleration.x = -max_acceleration
	elif event.is_action_pressed("player_right"):
		acceleration.x = max_acceleration
	else:
		movement_event_occured = false
	
	if event.is_action_pressed("player_target"):
		if target_mode or (not target_mode and counter_timer.value == 100):
			target_mode = not target_mode
		
			if target_mode:
				Engine.time_scale *= target_timescale
			else:
				Engine.time_scale *= 1 / target_timescale
	elif target_mode and target != null and event.is_action_pressed("player_counter"):
		if counter_timer.value > 0:
			counter_timer.value = 0
			counter()
			target_mode = false
			Engine.time_scale *= 1 / target_timescale
	
	if movement_event_occured:
		last_event = event
		timer_doubleclick.start()

func _on_rocket_killed():
	counter_timer.value = 100

func register_doubleclick_input_event(event):
	var boost_activated = true
	
	if event.is_action_pressed("player_up"):
		acceleration.y = -boost_acceleration
	elif event.is_action_pressed("player_down"):
		acceleration.y = boost_acceleration
	elif event.is_action_pressed("player_left"):
		acceleration.x = -boost_acceleration
	elif event.is_action_pressed("player_right"):
		acceleration.x = boost_acceleration
	else:
		boost_activated = false
	
	if boost_activated:
		timer_boost.start()

func _process(delta):
	delta = delta / Engine.time_scale
	
	if not target_mode:
		counter_timer.value += (delta / COUNTER_TIMER_FILL_TIME) * 60
	else:
		counter_timer.value -= (delta / COUNTER_TIMER_ACTIVE_TIME) * 60
		
		if counter_timer.value == 0:
			target_mode = false
			Engine.time_scale *= 1 / target_timescale
	
	update()

func _physics_process(delta):
	velocity += acceleration * delta
	
	if timer_boost.is_stopped():
		velocity = velocity.clamped(max_speed)
	else:
		velocity = velocity.clamped(boost_speed)
	
	position += velocity * delta

func hit_by_rocket():
	print("fuck me")

func _draw():
	if target_mode:
		target()

# TODO Rename
func target():
	var rockets = get_tree().get_nodes_in_group("rockets")
	
	var closest_rocket = null
	var closest_distance = INF
	
	# Find closest targetable rocket
	# DEBUG: Draw activation radius, line to player
	for rocket in rockets:
		if DebugInfo.visible:
			draw_circle(to_local(rocket.position), TARGET_ACTIVATION_RADIUS, Color("11FFFF00"))
		
		var distance_to_mouse = get_global_mouse_position().distance_to(rocket.position)
		
		if distance_to_mouse <= TARGET_ACTIVATION_RADIUS and \
		distance_to_mouse < closest_distance:
			closest_distance = distance_to_mouse
			closest_rocket = rocket
	
	# Provide aim point
	if closest_rocket != null:
		target = closest_rocket
		target_offset = get_global_mouse_position() - closest_rocket.position
		
		draw_rect(Rect2(
			to_local(target.position + target_offset), 
			Vector2(8,8)
		), Color(1, 0, 0))
	else:
		target = null

func counter():
	var counter = tscn_counter.instance()
	counter.init(position, weakref(target), target_offset, TARGET_VISIBLE_RADIUS)
	get_node("/root/Main").add_child(counter)