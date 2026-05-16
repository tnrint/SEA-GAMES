extends Area2D

@export var max_hp: int = 60
var current_hp: int
var speed_multiplier: float = 1.0 # Added for slow effect

var path_follow = PathFollow2D

func setup(new_path_follow: PathFollow2D):
	path_follow = new_path_follow
	
func _ready():
	current_hp = max_hp

func _process(delta: float) -> void:
	# Added speed_multiplier to the movement calculation
	path_follow.progress += (100 * speed_multiplier) * delta
	
	if path_follow.progress_ratio >= 0.99:
		print("Bottle reached end → damage player")
		queue_free()

func apply_slow(multiplier: float, duration: float):
	speed_multiplier = multiplier
	await get_tree().create_timer(duration).timeout
	speed_multiplier = 1.0 # Reset to normal speed

func take_damage(amount: int):
	SFXManager.play("enemy_hit")
	current_hp -= amount
	print("Bottle HP:", current_hp)
	
	if current_hp <= 0:
		die()

func die():
	print("Bottle destroyed")
	queue_free()
