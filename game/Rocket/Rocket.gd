extends Sprite

onready var target_position = get_node("/root/Main/Player").position

var explosion_radius
var max_velocity = 180

var velocity

func _ready():
	var target_angle = get_angle_to(target_position)
	rotation = target_angle
	velocity = Vector2(cos(target_angle), sin(target_angle)) * max_velocity

func init(explosion_radius):
	self.explosion_radius = explosion_radius

func _physics_process(delta):
	position += velocity * delta
	
	if position.distance_to(target_position) < 1:
		get_parent().remove_child(self)
		queue_free()
	
	update()

func _draw():
	draw_circle(to_local(target_position), explosion_radius, Color(1, 0, 0, 0.5))