extends Node2D

@export var damage: int = 10
@export var fire_rate: float = 1.0

var enemies_in_range: Array = []
var can_shoot: bool = true

func _ready():
	# connect signals through code (NO ERROR this way)
	$Area2D.area_entered.connect(_on_area_entered)
	$Area2D.area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D):
	# detect ONLY your trash
	if area.has_method("setup"):   # matches your trash script
		enemies_in_range.append(area)
		print("Enemy detected")

func _on_area_exited(area: Area2D):
	if area in enemies_in_range:
		enemies_in_range.erase(area)
		print("Enemy left")

func _process(delta):
	if enemies_in_range.size() > 0:
		var target = get_closest_enemy()
		
		# rotate toward enemy
		look_at(target.global_position)

		# shoot if allowed
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

	if target:
		# since your trash has no HP system exposed,
		# we remove it to simulate damage
		target.queue_free()
		print("Shot trash")

	# play attack animation
	if $AnimatedSprite2D.sprite_frames.has_animation("attack"):
		$AnimatedSprite2D.play("attack")

	await get_tree().create_timer(fire_rate).timeout

	can_shoot = true

	# go back to idle if exists
	if $AnimatedSprite2D.sprite_frames.has_animation("idle"):
		$AnimatedSprite2D.play("idle")
