extends Area2D

var timer_doubleclick

var max_speed = 180
var max_acceleration = 120

var velocity = Vector2(0,0)
var acceleration = Vector2(0,0)

func _ready():
	timer_doubleclick = Timer.new()
	timer_doubleclick.wait_time = TimingConstants.TRESHOLD_DOUBLECLICK
	timer_doubleclick.one_shot = true
	add_child(timer_doubleclick)

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
	print("doubleclick")

func _physics_process(delta):
	velocity += acceleration * delta
	velocity = velocity.clamped(max_speed)
	
	position += velocity * delta

func hit_by_rocket():
	print("fuck me")