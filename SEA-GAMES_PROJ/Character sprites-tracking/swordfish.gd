extends CharacterBody2D

@export var charge_speed: float = 500.0
@export var return_speed: float = 200.0
@export var damage_amount: int = 20

enum { IDLE, CHARGING, RETURNING }
var state = IDLE

var target_node = null
var home_pos = Vector2.ZERO

# This helps the fish look at the right direction
@onready var sprite = $AnimatedSprite2D

func _ready():
	home_pos = global_position
	sprite.play("idle") # Start the animation

func _physics_process(delta):
	match state:
		IDLE:
			find_trash()
			rotation_degrees = 0 
			sprite.flip_v = false
			
		CHARGING:
			if is_instance_valid(target_node):
				var dir = (target_node.global_position - global_position).normalized()
				velocity = dir * charge_speed
				
				look_at(target_node.global_position)
				
				# If the fish is swimming left, flip it so it isn't upside down
				sprite.flip_v = abs(rotation_degrees) > 90
				
				var collision = move_and_collide(velocity * delta)
				
				if global_position.distance_to(target_node.global_position) < 25:
					hit_trash()
			else:
				state = RETURNING
				
		RETURNING:
			var dir = (home_pos - global_position).normalized()
			velocity = dir * return_speed
			look_at(home_pos)
			
			sprite.flip_v = abs(rotation_degrees) > 90
			
			move_and_slide()
			
			if global_position.distance_to(home_pos) < 5:
				state = IDLE
				velocity = Vector2.ZERO

func find_trash():
	var areas = $DetectionRange.get_overlapping_areas()
	for area in areas:
		if area.has_method("take_damage"):
			target_node = area
			state = CHARGING
			break

func hit_trash():
	if target_node.has_method("take_damage"):
		target_node.take_damage(damage_amount)
		CurrencyManager.add_currency_from_damage(damage_amount)
	state = RETURNING
