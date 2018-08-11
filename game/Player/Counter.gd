extends Area2D

export var speed = 300
var explosion_radius

var velocity = null

func init(position, target_position, explosion_radius):
	self.position = position
	self.explosion_radius = explosion_radius
	velocity = (target_position - position).normalized() * speed
	
	var collider = CircleShape2D.new()
	collider.radius = explosion_radius
	
	create_shape_owner(self)
	shape_owner_add_shape(get_shape_owners()[0], collider)

func _process(delta):
	position += velocity * delta

func _on_Counter_area_shape_entered(area_id, area, area_shape, self_shape):
	if area.is_in_group("rockets"):
		print("waddup")

func _draw():
	if DebugInfo.visible:
		draw_circle(Vector2(0,0), explosion_radius, Color("11FFFF00"))