extends Node2D

@export var damage: int = 25
@export var fire_rate: float = 0.5
@export var bubble_scene: PackedScene  # assign BubbleProjectile.tscn in Inspector

var enemies_in_range: Array = []
var can_shoot: bool = true

func _ready():
	$Area2D.area_entered.connect(_on_area_entered)
	$Area2D.area_exited.connect(_on_area_exited)

func _on_area_entered(area: Area2D):
	if area.has_method("take_damage"):
		enemies_in_range.append(area)

func _on_area_exited(area: Area2D):
	enemies_in_range.erase(area)

func _process(_delta):
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))

	if enemies_in_range.size() > 0 and can_shoot:
		var target = get_closest_enemy()
		look_at(target.global_position)
		shoot(target)

func get_closest_enemy() -> Area2D:
	var closest = enemies_in_range[0]
	var min_dist = global_position.distance_to(closest.global_position)
	for enemy in enemies_in_range:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = enemy
	return closest

func shoot(target: Area2D):
	can_shoot = false

	# Spawn bubble at tower position, pass target + damage
	var bubble = bubble_scene.instantiate()
	get_tree().current_scene.add_child(bubble)
	bubble.global_position = global_position
	bubble.target = target
	bubble.damage = damage

	# Play attack animation
	if $AnimatedSprite2D.sprite_frames.has_animation("Attack"):
		$AnimatedSprite2D.play("Attack")

	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

	if $AnimatedSprite2D.sprite_frames.has_animation("Idle"):
		$AnimatedSprite2D.play("Idle")
