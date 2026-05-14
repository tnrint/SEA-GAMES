extends Button

signal character_selected(character_data)

var character_data

@onready var icon_: TextureRect = $Icon
@onready var cost_label: Label = $PointCostLabel

func setup(data):
	character_data = data
	icon_.texture = data.icon
	cost_label.text = str(data.cost)

func _pressed():
	emit_signal("character_selected", character_data)
