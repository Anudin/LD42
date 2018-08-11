extends Sprite

# TODO Add ability to disrupt fly path
# TODO Plan for changing paths

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
	
	# TODO Fix this ugly hack, maybe project on a normal
	if position.distance_to(target_position) < 10:
		if position.distance_to(player.position) < explosion_radius:
			player.hit_by_rocket()
		
		get_parent().remove_child(self)
		queue_free()
	
	update()

func _draw():
	# Preview explosion radius
	draw_circle(to_local(target_position), explosion_radius, Color(1, 0, 0, 0.5))
	
	if DebugInfo.visible:
		draw_flight_prediction()

func draw_flight_prediction():
	var frames_passed = 0
	var preview_position = position
	var timescale = Engine.time_scale
	
	while preview_position.distance_to(target_position) > 10:
		if Engine.time_scale != timescale:
			return
		
		frames_passed += 1
		preview_position += velocity * (1.0/60) * timescale

		if frames_passed % int(20 * (1 / timescale)) == 0:
			draw_circle(to_local(preview_position), 5, Color("11FFFF00"))
		elif frames_passed > 1000:
			# TODO Fix this ugly hack, maybe project on a normal
			return