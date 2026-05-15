extends CanvasLayer

signal character_chosen(char_data: CharacterData)
var points := 200
var selected_character: CharacterData = null

@onready var point_label: Label = $TopBar/MarginContainer/HBoxContainer/PointContainer/PointLabel
@onready var character_bar: Control = $TopBar/MarginContainer/HBoxContainer/CharacterBar

var card_scene = preload("res://UI/CharacterCard.tscn")
var characters: Array[CharacterData] = []

func _ready() -> void:
	setup_characters()
	load_character_cards()
	update_points()
	CurrencyManager.currency_changed.connect(_on_currency_changed)
# -----------------------
# CHARACTER SETUP
# -----------------------
func setup_characters() -> void:
	characters = [
		CharacterData.new(
			"Fish", 
			50, 
			preload("res://UI/fish_icon.tres"),
			"res://character sprites-tracking/fishy.tscn"
			),
		CharacterData.new(
			"Ice Fish", 
			125, 
			preload("res://UI/icefish_icon.tres"),
            "res://character sprites-tracking/ice_fishy.tscn"
		),
		CharacterData.new(
			"Sword Fish", 
			75, 
			preload("res://UI/swordfish_icon.tres"),
			"res://Character sprites-tracking/Swordfish.tscn"  # adjust filename if needed
		),
		CharacterData.new(
			"JellyFish", 
			200, 
			preload("res://UI/jellyfish_icon.tres"),
			"res://Character sprites-tracking/jellyfish.tscn"  # adjust filename if needed
		),
		# Add more easily...
	]

# -----------------------
# UI SPAWNING
# -----------------------
func load_character_cards() -> void:
	for char_data in characters:
		create_card(char_data)

func create_card(char_data: CharacterData) -> void:
	var card: Button = card_scene.instantiate()
	
	# Add to the scene tree FIRST
	character_bar.add_child(card)
	
	# Then safely setup
	card.setup(char_data)
	
	# Connect the signal
	card.character_selected.connect(on_character_selected)

# -----------------------
# SELECTION
# -----------------------
func on_character_selected(char_data: CharacterData) -> void:
	selected_character = char_data
	print("Selected:", char_data.name)
	character_chosen.emit(char_data) 

# -----------------------
# POINTS
# -----------------------
func update_points() -> void:
	point_label.text = str(points)
	
func _on_currency_changed(new_amount: int) -> void:
	points = new_amount
	update_points()
