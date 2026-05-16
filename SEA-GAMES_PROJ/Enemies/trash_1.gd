extends Area2D

signal died
signal reached_end  # ← NEW: Emitted when enemy reaches the end of the path

@export var max_hp: int = 120
@export var speed: float = 50.0   # Made export for consistency

var current_hp: int
var speed_multiplier: float = 1.0
var path_follow: PathFollow2D = null

func setup(new_path_follow: PathFollow2D):
	path_follow = new_path_follow

func _ready():
	current_hp = max_hp

func _process(delta: float) -> void:
	if path_follow == null:
		return
	
	path_follow.progress += speed * speed_multiplier * delta
	global_position = path_follow.global_position
	
	# Check if reached the end of the path
	if path_follow.progress_ratio >= 0.99:
		reached_end.emit()      # Notify level to damage player HP
		queue_free()

func apply_slow(multiplier: float, duration: float):
	speed_multiplier = multiplier
	await get_tree().create_timer(duration).timeout
	speed_multiplier = 1.0

func take_damage(amount: int):
	SFXManager.play("enemy_hit")
	current_hp -= amount
	print("Trash HP:", current_hp)
	
	if current_hp <= 0:
		die()

func die():
	print("Trash destroyed")
	died.emit()
	queue_free()
