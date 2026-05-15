extends Control

@onready var grid: GridContainer = $CardGrid
@onready var selected_bar: HBoxContainer = $SelectedBar
@onready var start_button: Button = $TopBar/StartButton

var card_scene = preload("res://UI/CharacterCard.tscn")

var all_characters: Array[CharacterData] = [
	CharacterData.new("Fish",       50,  preload("res://UI/fish_icon.tres"),       "res://character sprites-tracking/fishy.tscn"),
	CharacterData.new("Ice Fish",   125, preload("res://UI/icefish_icon.tres"),   "res://character sprites-tracking/ice_fishy.tscn"),
	CharacterData.new("Sword Fish", 75,  preload("res://UI/swordfish_icon.tres"),  "res://character sprites-tracking/Swordfish.tscn"),
	CharacterData.new("Jellyfish",  200, preload("res://UI/jellyfish_icon.tres"), "res://Character sprites-tracking/jellyfish.tscn"),
	CharacterData.new("Saw Fish",   150, preload("res://UI/sawfish_icon.tres"),   "res://Character sprites-tracking/sawshark.tscn"),
]

func _ready() -> void:
	SelectedCharactersManager.clear_selection()
	populate_grid()
	start_button.pressed.connect(_on_StartButton_pressed)

func populate_grid() -> void:
	for child in grid.get_children():
		child.queue_free()
	
	for char_data in all_characters:
		var card = card_scene.instantiate()
		card.setup(char_data)
		card.character_selected.connect(_on_card_clicked)
		grid.add_child(card)

func _on_card_clicked(char_data: CharacterData) -> void:
	var success = SelectedCharactersManager.add_character(char_data)
	if success:
		add_selected_icon(char_data)
	else:
		print("Selection full or already selected!")

func add_selected_icon(char_data: CharacterData) -> void:
	var tex = TextureRect.new()
	tex.texture = char_data.icon
	tex.custom_minimum_size = Vector2(80, 80)
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	selected_bar.add_child(tex)

func _on_StartButton_pressed() -> void:
	if SelectedCharactersManager.selected_characters.size() == 0:
		print("Please select at least one character!")
		return
	
	# Pass the selected characters (with scene paths) to the game
	GameManager.selected_characters = SelectedCharactersManager.selected_characters.duplicate()
	
	get_tree().change_scene_to_file("res://Maps/area_1_1.tscn")
