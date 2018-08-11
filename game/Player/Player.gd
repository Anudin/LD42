extends Area2D

var tscn_counter = preload("res://Player/Counter.tscn")

# TODO Make counters correct fleight paths

export var target_mode_length = 3
export var target_timescale = .33
export var target_cone_angle = 45
export var boost_length_sec = 1
export var boost_acceleration = 480
export var boost_speed = 720

const TARGET_ACTIVATION_RADIUS = 200
# TODO Rename TARGET_EXPLOSION_RADIUS, or even better move to Counter
const TARGET_VISIBLE_RADIUS = 60

var timer_doubleclick
var timer_boost

var max_speed = 180
var max_acceleration = 120

var velocity = Vector2(0,0)
var acceleration = Vector2(0,0)

var target_mode = false
var target_position = null

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
	
	if event.is_pressed() and not timer_doubleclick.is_stopped():
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
		target_mode = not target_mode
		
		if target_mode:
			Engine.time_scale *= target_timescale
		else:
			Engine.time_scale *= 1 / target_timescale
	elif target_mode and target_position != null and event.is_action_pressed("player_counter"):
		counter()
		target_mode = false
		Engine.time_scale *= 1 / target_timescale
	
	if movement_event_occured:
		timer_doubleclick.start()

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
			draw_line(Vector2(0,0), to_local(rocket.position), Color("11FFFF00"))
			draw_circle(to_local(rocket.position), TARGET_ACTIVATION_RADIUS, Color("11FFFF00"))
		
		var distance_to_mouse = get_global_mouse_position().distance_to(rocket.position)
		
		if distance_to_mouse <= TARGET_ACTIVATION_RADIUS and \
		distance_to_mouse < closest_distance:
			closest_distance = distance_to_mouse
			closest_rocket = rocket
	
	# Provide aim point
	if closest_rocket != null:
		var rocket_to_mouse = get_global_mouse_position() - closest_rocket.position
		var rocket_to_player = position - closest_rocket.position
		
		var direction = rocket_to_mouse.normalized()
		var hit_angle = direction.angle_to(rocket_to_player)
		
		if hit_angle < -target_cone_angle:
			direction = direction.rotated(hit_angle + target_cone_angle)
		elif hit_angle > target_cone_angle:
			direction = direction.rotated(hit_angle - target_cone_angle)
		
		target_position = closest_rocket.position + direction * TARGET_VISIBLE_RADIUS
		
		draw_rect(Rect2(
			to_local(target_position), 
			Vector2(8,8)
		), Color(1, 0, 0))
	else:
		target_position = null

func counter():
	var counter = tscn_counter.instance()
	counter.init(position, target_position, TARGET_VISIBLE_RADIUS)
	get_node("/root/Main").add_child(counter)