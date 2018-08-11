extends Area2D

export var boost_length_sec = 1
export var boost_acceleration = 480
export var boost_speed = 720

var timer_doubleclick
var timer_boost

var max_speed = 180
var max_acceleration = 120

var velocity = Vector2(0,0)
var acceleration = Vector2(0,0)

func _ready():
	timer_doubleclick = Timer.new()
	timer_doubleclick.wait_time = TimingConstants.TRESHOLD_DOUBLECLICK
	timer_doubleclick.one_shot = true
	add_child(timer_doubleclick)
	
	timer_boost = Timer.new()
	timer_boost.wait_time = boost_length_sec
	timer_boost.one_shot = true
	add_child(timer_boost)

func _input(event):
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

func _physics_process(delta):
	velocity += acceleration * delta
	
	if timer_boost.is_stopped():
		velocity = velocity.clamped(max_speed)
	else:
		velocity = velocity.clamped(boost_speed)
	
	position += velocity * delta

func hit_by_rocket():
	print("fuck me")