extends Area2D

signal died
@export var max_hp: int = 60
var current_hp: int
var speed_multiplier: float = 1.0 # Added for slow effect

var path_follow: PathFollow2D = null

func setup(new_path_follow: PathFollow2D):
	path_follow = new_path_follow
	
func _ready():
	current_hp = max_hp

func _process(delta):
	if path_follow == null:
		return

	path_follow.progress += 100 * speed_multiplier * delta

	global_position = path_follow.global_position

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
	died.emit()   # ⭐ tell the level this enemy is dead
	queue_free()
