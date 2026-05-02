extends Area2D

@export var max_hp: int = 120   # slow = tanky
var current_hp: int

var path_follow = PathFollow2D

func setup(new_path_follow: PathFollow2D):
	path_follow = new_path_follow
	
func _ready():
	current_hp = max_hp

func _process(delta: float) -> void:
	path_follow.progress += 50 * delta
	
	if path_follow.progress_ratio >= 0.99:
		print("Trash reached end → damage player")
		queue_free()

func take_damage(amount: int):
	current_hp -= amount
	print("Trash HP:", current_hp)
	
	if current_hp <= 0:
		die()

func die():
	print("Trash destroyed")
	queue_free()
