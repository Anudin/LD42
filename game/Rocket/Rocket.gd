extends Sprite

# TODO Add ability to disrupt fly path
# TODO Add path prediction, plan for changing paths

onready var player = get_node("/root/Main/Player")
onready var target_position = player.position

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
		if position.distance_to(player.position) < explosion_radius:
			player.hit_by_rocket()
		
		get_parent().remove_child(self)
		queue_free()
	
	update()

func _draw():
	# Preview explosion radius
	draw_circle(to_local(target_position), explosion_radius, Color(1, 0, 0, 0.5))
	
	# Preview flight path
	var frames_passed = 0
	var preview_position = position
	
	while preview_position.distance_to(target_position) > 1:
		frames_passed += 1
		preview_position += velocity * (1.0/60)
	
		if frames_passed % 20 == 0:
			draw_circle(to_local(preview_position), 5, Color(1, 1, 1))