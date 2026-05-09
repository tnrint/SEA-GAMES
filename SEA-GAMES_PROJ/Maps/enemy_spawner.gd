extends Node2D

@export_group("Scenes")
@export var bottle_scene: PackedScene
@export var trash_scene: PackedScene 
@export var trashbag_scene: PackedScene

@export_group("Spawn Settings")
@export var base_spawn_delay: float = 2.0
@export var min_spawn_delay: float = 0.4

var current_wave: int = 1
var enemies_to_spawn: int = 5
var enemies_spawned: int = 0

func _ready():
	start_wave()

func start_wave():
	print("Starting Wave:", current_wave)
	enemies_spawned = 0
	# Number of enemies increases slightly each wave
	enemies_to_spawn = 5 + (current_wave * 3)
	spawn_wave()

func spawn_wave():
	while enemies_spawned < enemies_to_spawn:
		spawn_enemy()
		enemies_spawned += 1

		# Delay between individual enemy spawns
		var delay = max(min_spawn_delay, base_spawn_delay - (current_wave * 0.1))
		await get_tree().create_timer(delay).timeout

	end_wave()

func spawn_enemy():
	var enemy
	var path = get_parent().get_node("Path2D")
	
	# --- Weighted Spawn Logic ---
	var roll = randf() 
	
	if roll < 0.5:
		# 50% chance: Fast/Weak Bottle
		enemy = bottle_scene.instantiate()
	elif roll < 0.8:
		# 30% chance: Standard Trash
		enemy = trash_scene.instantiate()
	else:
		# 20% chance: Tanky Trashbag
		enemy = trashbag_scene.instantiate()

	# --- Setup Path Hierarchy ---
	var new_path_follow = PathFollow2D.new()
	new_path_follow.loop = false
	
	path.add_child(new_path_follow)
	new_path_follow.add_child(enemy)
	
	# Tell the enemy which PathFollow2D it belongs to
	if enemy.has_method("setup"):
		enemy.setup(new_path_follow)

func end_wave():
	print("Wave ", current_wave, " finished!")
	# Wait for 4 seconds before the next wave starts
	await get_tree().create_timer(4.0).timeout
	current_wave += 1
	start_wave()
