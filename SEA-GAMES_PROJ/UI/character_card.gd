extends Button

signal character_selected(character_data: CharacterData)

var character_data: CharacterData

func setup(data: CharacterData) -> void:
	character_data = data
	
	# Icon
	var icon_rect = get_node_or_null("Icon")
	if icon_rect and icon_rect is TextureRect:
		icon_rect.texture = data.icon
		icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	else:
		push_error("Icon node not found in CharacterCard!")

	# Cost
	var cost_label = get_node_or_null("PointCostLabel")
	if cost_label and cost_label is Label:
		cost_label.text = str(data.cost)

	# Name
	var name_label = get_node_or_null("NameLabel")
	if name_label and name_label is Label and data.character_name != "":
		name_label.text = data.character_name

	tooltip_text = data.character_name if data.character_name else "Character"


func _pressed() -> void:
	if character_data:
		character_selected.emit(character_data)


func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
