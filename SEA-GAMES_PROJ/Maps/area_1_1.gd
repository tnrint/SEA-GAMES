extends Node2D

# =====================================================
# LEVEL CONFIG
# =====================================================
var level_id := 1

# =====================================================
# CHARACTER SYSTEM
# =====================================================
var character_scene = preload("res://UI/Character.tscn")
var selected_character: CharacterData = null

# =====================================================
# ENEMY SYSTEM
# =====================================================
var enemies_alive := 0
var level_finished := false

# =====================================================
# REFERENCES
# =====================================================
@onready var level_hud = $LevelHUD
@onready var path_follow = $Path2D/PathFollow2D
@onready var level_complete_ui = $LevelCompletePanel

# =====================================================
# READY
# =====================================================
func _ready() -> void:
	print("LEVEL STARTED: ", level_id)

	# HUD setup
	level_hud.character_chosen.connect(_on_character_chosen)
	level_hud.setup_with_selected_characters(
		SelectedCharactersManager.selected_characters
	)

	# TEMP TEST ENEMY SPAWN
	spawn_enemy(preload("res://Enemies/bottle_trash.tscn"), Vector2(500, 300))


# =====================================================
# INPUT (CHARACTER PLACEMENT)
# =====================================================
func _unhandled_input(event):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		try_spawn_character(get_global_mouse_position())


func try_spawn_character(pos: Vector2) -> void:
	if selected_character == null:
		print("No character selected!")
		return

	if !CurrencyManager.spend_currency(selected_character.cost):
		print("Not enough currency!")
		return

	spawn_character(pos, selected_character)


func spawn_character(pos: Vector2, char_data: CharacterData) -> void:
	var character = character_scene.instantiate()
	add_child(character)
	character.global_position = pos
	character.setup(char_data)


func _on_character_chosen(char_data: CharacterData) -> void:
	selected_character = char_data
	print("Now placing:", char_data.character_name)


# =====================================================
# ENEMY SYSTEM
# =====================================================
func spawn_enemy(enemy_scene: PackedScene, pos: Vector2) -> void:
	var enemy = enemy_scene.instantiate()
	add_child(enemy)

	enemies_alive += 1

	# IMPORTANT: give enemy path
	enemy.setup(path_follow)

	# connect death signal
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died)

	print("Enemy spawned. Total:", enemies_alive)


func _on_enemy_died() -> void:
	enemies_alive -= 1
	print("Enemy died. Remaining:", enemies_alive)
	check_win_condition()


# =====================================================
# WIN CONDITION
# =====================================================
func check_win_condition() -> void:
	if level_finished:
		return

	if enemies_alive <= 0:
		print("LEVEL COMPLETE!")
		show_level_complete()

func show_level_complete():
	level_finished = true
	level_complete_ui.visible = true
	

func _on_button_pressed() -> void:
	GameManager.level_completed(level_id)
