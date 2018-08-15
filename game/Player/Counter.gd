extends Area2D

export var speed = 1500.0
const explosion_radius = 60

var shape_owner

var velocity = null

func _ready():
	var collider = CircleShape2D.new()
	collider.radius = explosion_radius
	shape_owner = create_shape_owner(self)
	shape_owner_add_shape(get_shape_owners()[0], collider)

func init(position, ref_target, target_offset):
	self.position = position
	
	var target = ref_target.get_ref()
	velocity = ((target.position + target_offset) - position).normalized() * speed

func _process(delta):
	position += velocity * delta

func _draw():
	draw_circle(Vector2(0,0), explosion_radius, Color("11FFFF00"))

func disable_collider_and_queue_delete():
	shape_owner_set_disabled(shape_owner, true)
	get_tree().queue_delete(self)

func _on_Counter_area_shape_entered(area_id, area, area_shape, self_shape):
	if area.is_in_group("rockets"):
		disable_collider_and_queue_delete()

func _on_VisibilityNotifier2D_screen_exited():
	disable_collider_and_queue_delete()
