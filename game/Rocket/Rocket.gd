extends Area2D

signal exploded
signal killed

onready var collision_shape = get_node("CollisionShape2D")
onready var animator = get_node("AnimationPlayer")
onready var audio_startup = get_node("AudioStartup")
onready var audio_explode = get_node("AudioExplode")

var explosion_radius = 16
var initial_velocity = 30
var time_before_explosion = 1.5

var velocity
var hit = false
var rotate_velocity = 0

var player = null
var target_position = null

func _ready():
	player = get_tree().current_scene.find_node("Player")
	
	connect("exploded", get_tree().current_scene, "_on_Rocket_exploded", [weakref(self)])
	connect("killed", get_tree().current_scene, "_on_Rocket_killed")
	connect("killed", player, "_on_Rocket_killed")
	
	align_towards_target()
	setup_start_acceleration()
	
	audio_startup.play()

func setup_start_acceleration():
	var tween_startup_velocity = Tween.new()
	add_child(tween_startup_velocity)
	
	tween_startup_velocity.interpolate_property(
		self,
		"velocity", velocity, velocity * 10, 1,
		Tween.TRANS_EXPO, Tween.EASE_IN, 0)
		
	tween_startup_velocity.start()

func align_towards_target():
	target_position = player.position
	var target_angle = get_angle_to(target_position)
	rotation = target_angle
	velocity = Vector2(cos(target_angle), sin(target_angle)) * initial_velocity

func _physics_process(delta):
	position += velocity * delta
	rotate(rotate_velocity * delta)

	if not animator.assigned_animation.begins_with("explode") \
		and not hit:
		if ((target_position - position) / velocity).x <= 0:
			if position.distance_to(player.position) < explosion_radius:
				player.hit_by_rocket()
			
			explode()
	
	update()

var anim_exhaust_radius = 0

func _draw():
	if not animator.assigned_animation.begins_with("explode") \
		and not hit:
		draw_exhaust()
		draw_explosion_preview()

func draw_exhaust():
	draw_circle(Vector2(-18, 0), anim_exhaust_radius, Color("FF0000"))
	draw_circle(Vector2(-18, 0), anim_exhaust_radius / 2, Color("FFFF00"))

func draw_explosion_preview():
	draw_circle(to_local(target_position), explosion_radius, Color(1, 0, 0, 0.1))
	draw_circle(to_local(target_position), 4, Color(1, 0, 0, 0.8))
	draw_line(Vector2(0,0), to_local(target_position - velocity.normalized() * explosion_radius), Color("33FFFF00"), 2, false)

func explode(kill = false):
	velocity *= .15
	collision_shape.disabled = true
	audio_explode.play()
	
	if not kill:
		animator.play("explode")
	else:
		animator.play("explode_kill")
		get_node("Particles2D").emitting = true
	
	emit_signal("exploded")

func _on_Rocket_area_shape_entered(area_id, area, area_shape, self_shape):
	if area.is_in_group("counters"):
		hit = true
		
		var prev_velocity = velocity
		
		velocity = (position - area.position).normalized() * velocity.length()
		rotate_velocity = prev_velocity.angle_to(velocity)
		rotate_velocity /= abs(rotate_velocity) # Normalize
		rotate_velocity *= 2 * PI * (clamp(velocity.length() / 600, 0.1, 1) * 2)
		
		get_tree().create_timer(time_before_explosion, false).connect("timeout", self, "explode")
	elif area.is_in_group("rockets") and (hit or area.hit):
		explode(true)
		emit_signal("killed")
	elif area == player:
		explode()

func _on_AnimationPlayer_animation_finished(anim_name):
	set_process(false)
	set_physics_process(false)
	get_tree().queue_delete(self)

func _on_VisibilityNotifier2D_screen_exited():
	collision_shape.disabled = true
	get_tree().queue_delete(self)
