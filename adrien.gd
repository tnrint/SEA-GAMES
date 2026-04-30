extends Node2D

@export var damage: int = 10
@export var fire_rate: float = 1.0

var enemies_in_range = []
var can_shoot = true

func _on_area_2d_area_entered(area):
	# detect trash
	if area.has_method("setup"):  # your trash has setup()
		enemies_in_range.append(area)

func _on_area_2d_area_exited(area):
	enemies_in_range.erase(area)

func _process(delta):
	if enemies_in_range.size() > 0 and can_shoot:
		var target = get_first_enemy()
		shoot(target)

func get_first_enemy():
	return enemies_in_range[0]

func shoot(target):
	can_shoot = false

	if target:
		# since your trash has no damage system,
		# we simulate it by removing it
		target.queue_free()

	$AnimatedSprite2D.play("attack")

	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
	$AnimatedSprite2D.play("idle")
