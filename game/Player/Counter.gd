extends Area2D

# TODO Remove out of screen

export var speed = 500.0
var explosion_radius

var ref_target
var target_offset

var velocity

func init(position, ref_target, target_offset, explosion_radius):
	self.ref_target = ref_target
	self.target_offset = target_offset
	self.position = position
	self.explosion_radius = explosion_radius
	
	var collider = CircleShape2D.new()
	collider.radius = explosion_radius
	create_shape_owner(self)
	shape_owner_add_shape(get_shape_owners()[0], collider)

func _process(delta):
	if ref_target.get_ref():
		var target = ref_target.get_ref()
		velocity = ((target.position + target_offset) - position).normalized() * speed
	
	position += velocity * delta

func _draw():
	if DebugInfo.visible:
		draw_circle(Vector2(0,0), explosion_radius, Color("11FFFF00"))