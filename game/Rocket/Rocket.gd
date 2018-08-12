extends Area2D

signal rocket_killed

onready var player = get_node("/root/Main/Player")
onready var target_position = player.position

var explosion_radius
var initial_velocity = 60

var velocity
var acceleration = 1
var tween_initial_acceleration

var pushed = false

func _ready():
	var target_angle = get_angle_to(target_position)
	rotation = target_angle
	velocity = Vector2(cos(target_angle), sin(target_angle)) * initial_velocity
	
	# Accelerate on startup
	tween_initial_acceleration = Tween.new()
	add_child(tween_initial_acceleration)
	
	tween_initial_acceleration.interpolate_method(self, "set_velocity", velocity, velocity * 10, 1,
		Tween.TRANS_EXPO,
		Tween.EASE_IN,
		0)
	tween_initial_acceleration.start()

func set_velocity(value):
	velocity = value

func init(explosion_radius):
	self.explosion_radius = explosion_radius

func _physics_process(delta):
	position += velocity * delta
	
	if not pushed:
		# TODO Fix this ugly hack, maybe project on a normal
		if position.distance_to(target_position) < 10:
			if position.distance_to(player.position) < explosion_radius:
				player.hit_by_rocket()
			
			get_tree().queue_delete(self)
	
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
		velocity += (position - area.position).normalized() * 180
		rotate(original_velocity.angle_to(velocity))
		pushed = true
		get_tree().queue_delete(area)
	elif area.is_in_group("rockets"):
		emit_signal("rocket_killed")
		get_tree().queue_delete(self)

func _on_VisibilityNotifier2D_screen_exited():
	get_tree().queue_delete(self)
