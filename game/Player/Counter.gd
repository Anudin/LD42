extends Area2D

# TODO Remove out of screen

export var speed = 1500.0
var explosion_radius

var ref_target
var target_offset

var velocity

var shape_owner

func init(position, ref_target, target_offset, explosion_radius):
	self.ref_target = ref_target
	self.target_offset = target_offset
	self.position = position
	self.explosion_radius = explosion_radius
	
	var collider = CircleShape2D.new()
	collider.radius = explosion_radius
	shape_owner = create_shape_owner(self)
	shape_owner_add_shape(get_shape_owners()[0], collider)
	
	var target = ref_target.get_ref()
	velocity = ((target.position + target_offset) - position).normalized() * speed

func _process(delta):
	position += velocity * delta

func _draw():
	draw_circle(Vector2(0,0), explosion_radius, Color("11FFFF00"))