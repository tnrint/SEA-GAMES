extends Node2D

@export var damage: int = 25   # good demo value
@export var fire_rate: float = 1.0

var enemies_in_range: Array = []
var can_shoot: bool = true

func _ready():
	$Area2D.area_entered.connect(_on_area_entered)
	$Area2D.area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D):
	if area.has_method("take_damage"):
		enemies_in_range.append(area)
		print("Enemy detected")

func _on_area_exited(area: Area2D):
	if area in enemies_in_range:
		enemies_in_range.erase(area)

func _process(delta):
	# clean invalid enemies
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))

	if enemies_in_range.size() > 0:
		var target = get_closest_enemy()

		# rotate toward enemy
		look_at(target.global_position)

		if can_shoot:
			shoot(target)

func get_closest_enemy():
	var closest = enemies_in_range[0]
	var min_dist = global_position.distance_to(closest.global_position)

	for enemy in enemies_in_range:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = enemy

	return closest

func shoot(target):
	can_shoot = false

	if target and target.has_method("take_damage"):
		target.take_damage(damage)
		print("Tower dealt:", damage)

	# play animation
	if $AnimatedSprite2D.sprite_frames.has_animation("attack"):
		$AnimatedSprite2D.play("attack")

	await get_tree().create_timer(fire_rate).timeout

	can_shoot = true

	if $AnimatedSprite2D.sprite_frames.has_animation("idle"):
		$AnimatedSprite2D.play("idle")
