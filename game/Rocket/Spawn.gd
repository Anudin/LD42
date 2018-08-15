extends Position2D

export(PackedScene) var tscn_rocket

var available = true
var timer_available_cooldown

func _ready():
	timer_available_cooldown = Timer.new()
	timer_available_cooldown.wait_time = 1
	timer_available_cooldown.one_shot = true
	timer_available_cooldown.connect("timeout", self, "set", ["available", true])
	add_child(timer_available_cooldown)

func spawn_rocket(speed, explosion_radius):
	if available:
		available = false
		
		var rocket = tscn_rocket.instance()
		rocket.position = position
		rocket.initial_velocity = speed
		rocket.explosion_radius = explosion_radius
		get_tree().current_scene.add_child(rocket)
		
		timer_available_cooldown.start()
		return true
	
	return false