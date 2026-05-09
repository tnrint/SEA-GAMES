extends Area2D

@export var speed: float = 500.0
@export var damage: int = 15

var target: Node2D = null
var launcher: Node2D = null
var returning: bool = false

func _ready():
	z_index = 10
	set_as_top_level(true) 
	if not is_instance_valid(target):
		returning = true

func _process(delta: float):
	var destination: Vector2
	
	# Decide if we are going TO the enemy or BACK to the tower
	if not returning and is_instance_valid(target):
		destination = target.global_position
	elif is_instance_valid(launcher):
		destination = launcher.global_position
		returning = true # Switch to return mode if target died
	else:
		queue_free()
		return

	# Move toward destination
	var direction = global_position.direction_to(destination)
	global_position += direction * speed * delta
	look_at(destination)

	# Check for "Arrival"
	if global_position.distance_to(destination) < 20.0:
		if not returning:
			if is_instance_valid(target) and target.has_method("take_damage"):
				target.take_damage(damage)
			returning = true
		else:
			queue_free()
