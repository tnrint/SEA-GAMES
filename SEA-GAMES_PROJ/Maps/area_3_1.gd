extends Node2D

# =====================================================
# LEVEL CONFIG
# =====================================================
var level_id := 7
var current_wave := 0
var total_waves := 4
var is_wave_transitioning := false

# =====================================================
# PLAYER HP SYSTEM (ADDED)
# =====================================================
var max_hp: int = 100
var current_hp: int = 100

# =====================================================
# CHARACTER SYSTEM
# =====================================================
var character_scene = preload("res://UI/Character.tscn")
var selected_character: CharacterData = null
var is_placing: bool = false

# =====================================================
# ENEMY SYSTEM
# =====================================================
var enemies_alive := 0
var level_finished := false

# Wave Configuration (50 enemies per wave - Area 3 difficulty)
var wave_configs = [
	{ "count": 50, "enemy_scene": preload("res://Enemies/bottle_trash.tscn") },
	{ "count": 50, "enemy_scene": preload("res://Enemies/trashbag_trash.tscn") },
	{ "count": 50, "enemy_scene": preload("res://Enemies/trash_1.tscn") },
	{ "count": 50, "enemy_scene": preload("res://Enemies/trashbag_trash.tscn") }
]

# =====================================================
# REFERENCES
# =====================================================
@onready var level_hud = $LevelHUD
@onready var level_complete_ui = $LevelCompletePanel

# ADDED UI
@onready var hp_label: Label = $LevelHUD/HPLabel
@onready var game_over_ui = $LevelFailPanel

var all_paths: Array[Path2D] = []

# =====================================================
# READY
# =====================================================
func _ready() -> void:
	print("LEVEL STARTED: Area 3-1 (Level ", level_id, ")")
	
	current_hp = max_hp
	update_hp_ui()
	
	_find_all_paths()
	
	level_hud.character_chosen.connect(_on_character_chosen)
	level_hud.setup_with_selected_characters(SelectedCharactersManager.selected_characters)
	
	start_next_wave()


func _find_all_paths() -> void:
	all_paths.clear()
	for child in get_children():
		if child is Path2D:
			all_paths.append(child)
	
	print("Found ", all_paths.size(), " paths (UL1, UL2, UR1, UR2)")


# =====================================================
# HP SYSTEM (ADDED)
# =====================================================
func update_hp_ui() -> void:
	if hp_label:
		hp_label.text = "HP: " + str(current_hp) + "/" + str(max_hp)


func take_damage(amount: int = 10) -> void:
	current_hp -= amount
	update_hp_ui()
	print("Player took damage! HP left:", current_hp)
	
	if current_hp <= 0:
		game_over()


func game_over() -> void:
	print("💀 GAME OVER - Player HP reached 0")
	
	is_wave_transitioning = true
	level_finished = true
	
	if game_over_ui:
		game_over_ui.visible = true
	else:
		push_error("GameOverPanel not found! Add LevelFailPanel to scene.")


# =====================================================
# WAVE SYSTEM
# =====================================================
func start_next_wave() -> void:
	if is_wave_transitioning or current_hp <= 0:
		return
	
	current_wave += 1
	if current_wave > total_waves:
		return
	
	is_wave_transitioning = true
	print("🚀 Starting Wave ", current_wave, "/", total_waves, " - 50 enemies")
	
	var config = wave_configs[current_wave - 1]
	spawn_wave(config.count, config.enemy_scene)


func spawn_wave(count: int, enemy_scene: PackedScene) -> void:
	for i in range(count):
		await get_tree().create_timer(0.4).timeout
		spawn_single_enemy(enemy_scene)
	
	is_wave_transitioning = false


func spawn_single_enemy(enemy_scene: PackedScene) -> void:
	if not enemy_scene or all_paths.is_empty():
		return
	
	var random_path = all_paths[randi() % all_paths.size()]
	
	var path_follow = PathFollow2D.new()
	random_path.add_child(path_follow)
	path_follow.loop = false
	path_follow.rotates = false
	
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	
	enemy.setup(path_follow)
	enemies_alive += 1
	
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died.bind(path_follow))
	
	if enemy.has_signal("reached_end"):
		enemy.reached_end.connect(_on_enemy_reached_end)


func _on_enemy_died(path_follow: PathFollow2D) -> void:
	enemies_alive -= 1
	
	if path_follow and is_instance_valid(path_follow):
		path_follow.queue_free()
	
	check_win_condition()


func _on_enemy_reached_end() -> void:
	take_damage(10)


# =====================================================
# WIN CONDITION
# =====================================================
func check_win_condition() -> void:
	if level_finished or is_wave_transitioning or current_hp <= 0:
		return
	
	if enemies_alive <= 0 and current_wave >= total_waves:
		print("🎉 LEVEL COMPLETE! Area 3-1 Cleared!")
		show_level_complete()
	elif enemies_alive <= 0:
		print("Wave ", current_wave, " finished → Next wave...")
		await get_tree().create_timer(2.3).timeout
		start_next_wave()


func show_level_complete():
	level_finished = true
	level_complete_ui.visible = true


# =====================================================
# CHARACTER PLACEMENT
# =====================================================
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and is_placing and selected_character != null:
			try_spawn_character(get_global_mouse_position())
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			cancel_placement()


func try_spawn_character(pos: Vector2) -> void:
	if selected_character == null:
		return
	
	if not CurrencyManager.spend_currency(selected_character.cost):
		print("Not enough currency!")
		return
	
	spawn_character(pos, selected_character)
	cancel_placement()


func spawn_character(pos: Vector2, char_data: CharacterData) -> void:
	var character = character_scene.instantiate()
	add_child(character)
	character.global_position = pos
	character.setup(char_data)


func _on_character_chosen(char_data: CharacterData) -> void:
	selected_character = char_data
	is_placing = true
	print("Now placing: ", char_data.character_name)


func cancel_placement() -> void:
	selected_character = null
	is_placing = false
	print("Placement cancelled")


# =====================================================
# BUTTONS
# =====================================================
func _on_button_pressed() -> void:
	GameManager.level_completed(level_id)


func retry_pressed() -> void:
	get_tree().change_scene_to_file("res://Maps/area_3_1.tscn")
