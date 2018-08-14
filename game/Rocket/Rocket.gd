extends Area2D

signal rocket_exploded
signal rocket_killed

onready var player = get_node("/root/Main/Player")
onready var target_position = player.position

onready var collision_shape = get_node("CollisionShape2D")
onready var animation_player = get_node("AnimationPlayer")

var explosion_radius = 16
var initial_velocity = 30

var velocity
var acceleration = 1
var tween_initial_acceleration

var pushed = false
var spin = 0

var dead_timer

onready var audio_startup = get_node("AudioStartup")
onready var audio_explode = get_node("AudioExplode")

func _ready():
	audio_startup.play()
	connect("rocket_killed", get_node("/root/Main"), "_on_rocket_killed")
	connect("rocket_exploded", get_node("/root/Main"), "_on_rocket_exploded", [weakref(self)])
	connect("rocket_killed", player, "_on_rocket_killed")
	
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
	
	dead_timer = Timer.new()
	add_child(dead_timer)
	dead_timer.wait_time = 1.5
	dead_timer.connect("timeout", self, "explode")

func set_velocity(value):
	velocity = value

func _physics_process(delta):
	position += velocity * delta
	rotate(spin * delta)
	
	if not animation_player.is_playing() and not pushed:
		# TODO Fix this ugly hack, maybe project on a normal
		if position.distance_to(target_position) < 10:
			if position.distance_to(player.position) < explosion_radius:
				player.hit_by_rocket()
			
			explode()
	
	update()

func _draw():
	if not animation_player.is_playing() and not pushed:
		# Preview explosion radius
		draw_circle(to_local(target_position), explosion_radius, Color(1, 0, 0, 0.1))
		draw_circle(to_local(target_position), 4, Color(1, 0, 0, 0.8))
		draw_flight_prediction()

func draw_flight_prediction():
	draw_line(Vector2(0,0), to_local(target_position - velocity.normalized() * explosion_radius), Color("33FFFF00"), 2, false)

func _on_Rocket_area_shape_entered(area_id, area, area_shape, self_shape):
	if area.is_in_group("counters"):
		# TODO Add rotation depending on velocity (strength + direction)
		var original_velocity = velocity
		velocity = (position - area.position).normalized() * velocity.length()
		
		spin = original_velocity.angle_to(velocity)
		spin /= abs(spin)
		spin *= 2 * PI * (clamp(velocity.length() / 600, 0.1, 1) * 2)
		
		pushed = true
		area.shape_owner_set_disabled(area.shape_owner, true)
		get_tree().queue_delete(area)
		
		dead_timer.start()
	elif area.is_in_group("rockets") and (pushed or area.pushed):
		emit_signal("rocket_killed")
		explode(true)
	elif area == player:
		explode()
		yield(get_tree().create_timer(.25, false), "timeout")
		player.hit_by_rocket()

func _on_VisibilityNotifier2D_screen_exited():
	get_tree().queue_delete(self)

var dead = false

func explode(kill = false):
	if dead:
		return
	
	emit_signal("rocket_exploded")
	
	audio_explode.play()
	collision_shape.disabled = true
	velocity *= .15
	
	if not kill:
		animation_player.play("explode")
	else:
		get_node("Particles2D").emitting = true
		animation_player.play("explode_kill")

func _on_AnimationPlayer_animation_finished(anim_name):
	set_process(false)
	set_physics_process(false)
	dead = true
	
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = .3
	timer.start()
	timer.connect("timeout", get_tree(), "queue_delete", [self])
