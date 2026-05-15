extends CanvasLayer

signal character_chosen(char_data: CharacterData)

# Current selected character for placement
var selected_character: CharacterData = null

# UI references
@onready var point_label: Label = $TopBar/MarginContainer/HBoxContainer/PointContainer/PointLabel
@onready var character_bar: Control = $TopBar/MarginContainer/HBoxContainer/CharacterBar

var card_scene = preload("res://UI/CharacterCard.tscn")

# ---------------------------------------------------
# READY
# ---------------------------------------------------
func _ready() -> void:
	# Always sync with CurrencyManager at start
	update_points(CurrencyManager.get_currency())
	CurrencyManager.currency_changed.connect(_on_currency_changed)

# ---------------------------------------------------
# CALLED BY LEVEL WHEN LEVEL STARTS
# Level passes the 5 characters chosen in CharacterSelect
# ---------------------------------------------------
func setup_with_selected_characters(selected_list: Array[CharacterData]) -> void:
	# Clear old cards
	for child in character_bar.get_children():
		child.queue_free()
	
	# Create cards ONLY for selected characters
	for char_data in selected_list:
		create_card(char_data)

# ---------------------------------------------------
# CREATE CHARACTER CARD IN HUD BAR
# ---------------------------------------------------
func create_card(char_data: CharacterData) -> void:
	var card = card_scene.instantiate()
	character_bar.add_child(card)
	card.setup(char_data)
	card.character_selected.connect(_on_card_clicked)

# ---------------------------------------------------
# PLAYER CLICKED A CARD → choose character to place
# ---------------------------------------------------
func _on_card_clicked(char_data: CharacterData) -> void:
	selected_character = char_data
	print("Selected for placement: ", char_data.character_name)   # ← Fixed
	
	# Tell the LEVEL what was selected
	character_chosen.emit(char_data)

# ---------------------------------------------------
# POINTS / CURRENCY
# ---------------------------------------------------
func update_points(amount: int) -> void:
	point_label.text = str(amount)

func _on_currency_changed(new_amount: int) -> void:
	update_points(new_amount)
