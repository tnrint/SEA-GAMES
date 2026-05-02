extends Node2D

@export var trash_scene: PackedScene
@export var bottle_scene: PackedScene
@export var trashbag_scene: PackedScene

@export var base_spawn_delay: float = 2.0
@export var min_spawn_delay: float = 0.4

var current_wave: int = 1
var enemies_to_spawn: int = 5
var enemies_spawned: int = 0

func _ready():
	randomize()
	start_wave()

func start_wave():
	print("Starting Wave:", current_wave)

	enemies_spawned = 0
	enemies_to_spawn = 5 + (current_wave * 3)

	spawn_wave()

func spawn_wave():
	while enemies_spawned < enemies_to_spawn:
		spawn_enemy()
		enemies_spawned += 1

		var delay = max(min_spawn_delay, base_spawn_delay - (current_wave * 0.2))
		await get_tree().create_timer(delay).timeout

	end_wave()

func end_wave():
	print("Wave", current_wave, "finished")

	await get_tree().create_timer(3.0).timeout

	current_wave += 1
	start_wave()

func spawn_enemy():
	var enemy
	var path = get_parent().get_node("Path2D")

	# Randomly pick between bottle, tier1 trash, or tier2 trash
	var roll = randi() % 3
	match roll:
		0:
			enemy = bottle_scene.instantiate()
		1:
			enemy = trashbag_scene.instantiate()
			enemy.max_hp = 30   # starts as tier1 visually
		2:
			enemy = trashbag_scene.instantiate()
			enemy.max_hp = 60   # starts as tier2, transforms at 30 HP

	var new_path_follow = PathFollow2D.new()
	new_path_follow.progress = 0
	path.add_child(new_path_follow)
	new_path_follow.add_child(enemy)
	enemy.setup(new_path_follow)
