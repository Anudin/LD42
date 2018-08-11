extends Area2D

export var speed = 300

var velocity = null

func init(position, target_position, explosion_radius):
	self.position = position
	velocity = (target_position - position).normalized() * speed

func _process(delta):
	position += velocity * delta