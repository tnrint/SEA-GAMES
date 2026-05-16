extends Area2D

signal died
signal reached_end  # ← NEW: Emitted when enemy reaches the end of the path

@export var max_hp: int = 60
@export var speed: float = 80.0

var current_hp: int
var speed_multiplier: float = 1.0
var path_follow: PathFollow2D = null

func setup(new_path_follow: PathFollow2D):
	path_follow = new_path_follow

func _ready():
	current_hp = max_hp

func _process(delta: float):
	if path_follow == null:
		return
	
	# Move along the path
	path_follow.progress += speed * speed_multiplier * delta
	global_position = path_follow.global_position
	
	# Check if enemy reached the end of the path
	if path_follow.progress_ratio >= 0.99:
		reached_end.emit()
		queue_free()   # Remove enemy after reaching end

func apply_slow(multiplier: float, duration: float):
	speed_multiplier = multiplier
	await get_tree().create_timer(duration).timeout
	speed_multiplier = 1.0

func take_damage(amount: int):
	SFXManager.play("enemy_hit")
	current_hp -= amount
	print("Bottle HP:", current_hp)
	
	if current_hp <= 0:
		die()

func die():
	print("Bottle destroyed")
	died.emit()
	queue_free()
