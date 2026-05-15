extends Area2D

@export_group("Shotgun Stats")
@export var speed: float = 700.0
@export var max_range: float = 200.0
@export var max_damage: int = 30 
@export var min_damage: int = 5  

var direction: Vector2 = Vector2.ZERO
var distance_traveled: float = 0.0

func _process(delta):
	# Movement logic
	var move_step = direction * speed * delta
	global_position += move_step
	
	# Track distance for range and damage falloff
	distance_traveled += move_step.length()
	
	# Delete bullet if it goes past shotgun range
	if distance_traveled >= max_range:
		queue_free()

func _on_area_entered(area: Area2D):
	if area.has_method("take_damage"):
		# DAMAGE FALLOFF: Calculate damage based on distance
		var distance_percent = clamp(distance_traveled / max_range, 0.0, 1.0)
		var final_damage = lerp(max_damage, min_damage, distance_percent)
		
		area.take_damage(int(final_damage))
		
		# SLOW EFFECT: Tell the enemy to slow down
		if area.has_method("apply_slow"):
			area.apply_slow(0.5, 1.5) # 50% speed for 1.5 seconds
			
		queue_free() # Destroy bullet on hit
