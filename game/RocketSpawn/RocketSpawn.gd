extends Position2D

var tscn_rocket = preload("res://Rocket/Rocket.tscn")

var available = true
var timer_cooldown

func _ready():
	timer_cooldown = Timer.new()
	add_child(timer_cooldown)
	timer_cooldown.wait_time = 1
	timer_cooldown.one_shot = true
	timer_cooldown.connect("timeout", self, "make_available")

func make_available():
	available = true

func spawn_rocket(explosion_radius):
	if available:
		var rocket = tscn_rocket.instance()
		rocket.init(explosion_radius)
		rocket.position = position
		get_node("/root/Main").add_child(rocket)
		
		available = false
		timer_cooldown.start()
		return true
	
	return false