extends Node2D

var enemy_scene = preload("res://Enemies/trash_1.tscn")
var character_scene = preload("res://UI/Character.tscn")
var available_characters: Array[CharacterData] = []
var selected_character: CharacterData = null
var is_placing: bool = false  # 👈 add this

@onready var level_hud = $LevelHUD

func _ready() -> void:
	level_hud.character_chosen.connect(_on_character_chosen)
	level_hud.setup_with_selected_characters(
		SelectedCharactersManager.selected_characters
	)

# -----------------------
# CHARACTER PLACEMENT
# -----------------------
func _unhandled_input(event):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		if is_placing and selected_character != null: 
			try_spawn_character(get_global_mouse_position())
		elif event.button_index == MOUSE_BUTTON_RIGHT:  
			cancel_placement()

func try_spawn_character(pos: Vector2) -> void:
	if selected_character == null:
		print("No character selected for placement!")
		return
	if !CurrencyManager.spend_currency(selected_character.cost):
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
