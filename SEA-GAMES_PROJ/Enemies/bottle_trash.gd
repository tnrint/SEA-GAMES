extends Area2D

@export var max_hp: int = 60   # fast = lower HP
var current_hp: int

var path_follow = PathFollow2D

func setup(new_path_follow: PathFollow2D):
	path_follow = new_path_follow
	
func _ready():
	current_hp = max_hp

func _process(delta: float) -> void:
	path_follow.progress += 100 * delta
	
	if path_follow.progress_ratio >= 0.99:
		print("Bottle reached end → damage player")
		queue_free()

func take_damage(amount: int):
	current_hp -= amount
	print("Bottle HP:", current_hp)
	
	if current_hp <= 0:
		die()

func die():
	print("Bottle destroyed")
	queue_free()
