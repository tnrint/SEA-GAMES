extends Node2D

# =====================================================
# LEVEL CONFIG
# =====================================================
var level_id := 1
var current_wave := 0
var total_waves := 3
var is_wave_transitioning := false

# =====================================================
# PLAYER HP SYSTEM
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

# Wave Configuration
var wave_configs = [
	{ "path": 1, "count": 10, "enemy_scene": preload("res://Enemies/bottle_trash.tscn") },
	{ "path": 2, "count": 10, "enemy_scene": preload("res://Enemies/trashbag_trash.tscn") },
	{ "path": "both", "count": 10,
	  "enemy_scene1": preload("res://Enemies/bottle_trash.tscn"),
	  "enemy_scene2": preload("res://Enemies/trash_1.tscn") }
]

# =====================================================
# REFERENCES
# =====================================================
@onready var level_hud = $LevelHUD
@onready var path1: Path2D = $Path2D
@onready var path2: Path2D = $Path2D2
@onready var level_complete_ui = $LevelCompletePanel

# Add these two references (create them in the scene if they don't exist)
@onready var hp_label: Label = $LevelHUD/HPLabel  # ← Create this Label in LevelHUD
@onready var game_over_ui = $LevelFailPanel      # ← You need to add this panel

# =====================================================
# READY
# =====================================================
func _ready() -> void:
	current_hp = max_hp
	update_hp_ui()
	
	print("LEVEL STARTED: Area 1-1")
	
	level_hud.character_chosen.connect(_on_character_chosen)
	level_hud.setup_with_selected_characters(SelectedCharactersManager.selected_characters)
	
	start_next_wave()


func update_hp_ui() -> void:
	if hp_label:
		hp_label.text = "HP: " + str(current_hp) + "/" + str(max_hp)


# =====================================================
# PLAYER HP SYSTEM
# =====================================================
func take_damage(amount: int = 10) -> void:
	current_hp -= amount
	update_hp_ui()
	print("Player took damage! HP left:", current_hp)
	
	if current_hp <= 0:
		game_over()


func game_over() -> void:
	print("💀 GAME OVER - Player HP reached 0")
	# Stop everything
	is_wave_transitioning = true
	level_finished = true
	
	if game_over_ui:
		game_over_ui.visible = true
	else:
		push_error("GameOverPanel not found! Create it in the scene.")


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
	print("🚀 Starting Wave ", current_wave, "/", total_waves)
	
	var config = wave_configs[current_wave - 1]
	
	if config.path is String and config.path == "both":
		spawn_wave_on_path(path1, config.count, config.enemy_scene1)
		spawn_wave_on_path(path2, config.count, config.enemy_scene2)
	else:
		var selected_path = path1 if config.path == 1 else path2
		spawn_wave_on_path(selected_path, config.count, config.enemy_scene)


func spawn_wave_on_path(path2d: Path2D, count: int, enemy_scene: PackedScene) -> void:
	for i in range(count):
		await get_tree().create_timer(0.8).timeout
		spawn_single_enemy(path2d, enemy_scene)
	
	is_wave_transitioning = false


func spawn_single_enemy(path2d: Path2D, enemy_scene: PackedScene) -> void:
	if not enemy_scene:
		return
	
	var path_follow = PathFollow2D.new()
	path2d.add_child(path_follow)
	path_follow.loop = false
	path_follow.rotates = false
	
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	
	enemy.setup(path_follow)
	enemies_alive += 1
	
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died.bind(path_follow))
	
	# NEW: Connect to end of path signal
	if enemy.has_signal("reached_end"):
		enemy.reached_end.connect(_on_enemy_reached_end)


func _on_enemy_died(path_follow: PathFollow2D) -> void:
	enemies_alive -= 1
	if path_follow and is_instance_valid(path_follow):
		path_follow.queue_free()
	
	print("Enemy died. Remaining: ", enemies_alive)
	check_win_condition()


func _on_enemy_reached_end() -> void:
	take_damage(10)  # Change 10 to whatever damage you want per enemy


# =====================================================
# WIN CONDITION
# =====================================================
func check_win_condition() -> void:
	if level_finished or is_wave_transitioning or current_hp <= 0:
		return
	
	if enemies_alive <= 0 and current_wave >= total_waves:
		print("🎉 ALL WAVES CLEARED - LEVEL COMPLETE!")
		show_level_complete()
	elif enemies_alive <= 0 and current_wave < total_waves:
		print("Wave ", current_wave, " cleared. Starting next wave...")
		await get_tree().create_timer(2.0).timeout
		start_next_wave()


func show_level_complete():
	level_finished = true
	level_complete_ui.visible = true


# =====================================================
# CHARACTER PLACEMENT
# =====================================================
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if is_placing and selected_character != null:
				try_spawn_character(get_global_mouse_position())
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			cancel_placement()


func try_spawn_character(pos: Vector2) -> void:
	if selected_character == null:
		print("No character selected for placement!")
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


func _on_button_pressed() -> void:
	GameManager.level_completed(level_id)

func retry_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/CharacterSelect.tscn")
