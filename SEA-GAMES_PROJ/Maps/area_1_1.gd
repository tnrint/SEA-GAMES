extends Node2D

var enemy_scene = preload("res://Enemies/trash_1.tscn")
var character_scene = preload("res://UI/Character.tscn")

# Will hold the 5 characters the player selected
var available_characters: Array[CharacterData] = []
var selected_character: CharacterData = null

@onready var level_hud = $LevelHUD

func _ready() -> void:
	# Connect HUD → Level
	level_hud.character_chosen.connect(_on_character_chosen)
	
	# Tell HUD which characters were chosen in CharacterSelect screen
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
		try_spawn_character(get_global_mouse_position())

func try_spawn_character(pos: Vector2) -> void:
	if selected_character == null:
		print("No character selected for placement!")
		return
	
	# Spend currency
	if !CurrencyManager.spend_currency(selected_character.cost):
		print("Not enough currency!")
		return
	
	spawn_character(pos, selected_character)

func spawn_character(pos: Vector2, char_data: CharacterData) -> void:
	var character = character_scene.instantiate()
	add_child(character)
	character.global_position = pos
	character.setup(char_data)

# Called when player clicks a card in the HUD
func _on_character_chosen(char_data: CharacterData) -> void:
	selected_character = char_data
	print("Now placing: ", char_data.character_name)   # ← Fixed here
