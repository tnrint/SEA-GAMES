extends Node2D

var enemy_scene = preload("res://Enemies/trash_1.tscn")
var selected_character : CharacterData = null
var character_scene = preload("res://UI/Character.tscn")
@onready var level_hud = $LevelHUD   # make sure LevelHUD is child of level

func _ready() -> void:
	level_hud.character_chosen.connect(_on_character_chosen)
	
func _on_character_chosen(char_data: CharacterData) -> void:
	selected_character = char_data
	print("Level received selected character")
	
func _unhandled_input(event):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		try_spawn_character(get_global_mouse_position())

func try_spawn_character(pos: Vector2) -> void:
	if selected_character == null:
		return
	
	# 💰 Ask CurrencyManager to spend points
	if !CurrencyManager.spend_currency(selected_character.cost):
		print("Not enough currency!")
		return
	
	spawn_character(pos, selected_character)
	selected_character = null   # reset selection after placing
	
func spawn_character(pos: Vector2, char_data: CharacterData) -> void:
	var character = character_scene.instantiate()
	add_child(character)
	
	character.global_position = pos
	character.setup(char_data)
