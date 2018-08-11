extends Area2D

var max_speed = 180
var max_acceleration = 120

var velocity = Vector2(0,0)
var acceleration = Vector2(0,0)

func _input(event):
	if event.is_action_pressed("player_up"):
		acceleration.y = -max_acceleration
	elif event.is_action_pressed("player_down"):
		acceleration.y = max_acceleration
	elif event.is_action_pressed("player_left"):
		acceleration.x = -max_acceleration
	elif event.is_action_pressed("player_right"):
		acceleration.x = max_acceleration

func _physics_process(delta):
	velocity += acceleration * delta
	velocity = velocity.clamped(max_speed)
	
	position += velocity * delta

func hit_by_rocket():
	print("fuck me")