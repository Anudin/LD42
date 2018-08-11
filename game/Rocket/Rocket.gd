extends Area2D

# TODO Unlimited acceleration!

onready var player = get_node("/root/Main/Player")
onready var target_position = player.position

var explosion_radius
var max_velocity = 180

var velocity

var pushed = false
var destroyed = false

func _ready():
	var target_angle = get_angle_to(target_position)
	rotation = target_angle
	velocity = Vector2(cos(target_angle), sin(target_angle)) * max_velocity

func init(explosion_radius):
	self.explosion_radius = explosion_radius

func _physics_process(delta):
	position += velocity * delta
	
	if not pushed:
		# TODO Fix this ugly hack, maybe project on a normal
		if position.distance_to(target_position) < 10:
			if position.distance_to(player.position) < explosion_radius:
				player.hit_by_rocket()
			
			destroy()
	
	update()

func _draw():
	if not pushed:
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

func _on_Rocket_area_shape_entered(area_id, area, area_shape, self_shape):
	if area.is_in_group("counters"):
		var original_velocity = velocity
		velocity += (position - area.position).normalized() * 60
		rotate(original_velocity.angle_to(velocity))
		pushed = true
		
		area.get_parent().remove_child(area)
		area.queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	destroy()

func destroy():	
	if not destroyed:
		destroyed = true
		
		get_parent().remove_child(self)
		queue_free()