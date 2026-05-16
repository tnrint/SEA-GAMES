extends CanvasLayer

var current_tower = null
var tower_name: String = ""

@onready var tower_label    = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TowerLabel
@onready var close_btn      = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CloseButton
@onready var damage_value   = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/DamageValue
@onready var firerate_value = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/FireRateValue
@onready var points_value   = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer5/PointsValue
@onready var upgrade_btn    = $PanelContainer/MarginContainer/VBoxContainer/UpgradeButton

func _ready() -> void:
	print("UpgradePanel _ready called!")
	visible = false
	close_btn.pressed.connect(_on_close_pressed)
	upgrade_btn.pressed.connect(_on_upgrade_pressed)
	CurrencyManager.currency_changed.connect(_on_currency_changed)

func show_panel(tower, name: String) -> void:
	current_tower = tower
	tower_name = name
	visible = true
	refresh()

func refresh() -> void:
	if not current_tower:
		return

	var already_upgraded = UpgradeManager.is_upgraded(current_tower)
	tower_label.text  = tower_name + " Tower"
	points_value.text = str(CurrencyManager.get_currency()) + " pts"

	if tower_name == "Sawshark":
		var data = UpgradeManager.upgrade_data["Sawshark"]
		var total_cost = data["damage"]["cost"] + data["attack_duration"]["cost"]
		if already_upgraded:
			damage_value.text   = "Damage: %d (Maxed)" % current_tower.damage
			firerate_value.text = "Attack Duration: %.1fs (Maxed)" % current_tower.attack_duration
			upgrade_btn.text     = "Maxed out"
			upgrade_btn.disabled = true
		else:
			damage_value.text   = "Damage: %d → %d" % [current_tower.damage, current_tower.damage + data["damage"]["amount"]]
			firerate_value.text = "Attack Duration: %.1fs → %.1fs" % [current_tower.attack_duration, current_tower.attack_duration + data["attack_duration"]["amount"]]
			upgrade_btn.text     = "Upgrade all  —  %d pts" % total_cost
			upgrade_btn.disabled = CurrencyManager.get_currency() < total_cost

	elif tower_name == "Angler":
		var data = UpgradeManager.upgrade_data["Angler"]
		var total_cost = data["speed_multiplier"]["cost"] + data["buff_range"]["cost"]
		if already_upgraded:
			damage_value.text   = "Speed Buff: %.1fx (Maxed)" % current_tower.speed_multiplier
			firerate_value.text = "Buff Range: Maxed"
			upgrade_btn.text     = "Maxed out"
			upgrade_btn.disabled = true
		else:
			damage_value.text   = "Speed Buff: %.1fx → %.1fx" % [current_tower.speed_multiplier, current_tower.speed_multiplier + data["speed_multiplier"]["amount"]]
			firerate_value.text = "Buff Range: +%d" % data["buff_range"]["amount"]
			upgrade_btn.text     = "Upgrade all  —  %d pts" % total_cost
			upgrade_btn.disabled = CurrencyManager.get_currency() < total_cost
	elif tower_name == "Jellyfish":
		var data = UpgradeManager.upgrade_data["Jellyfish"]
		var total_cost = data["damage"]["cost"] + data["pulse_rate"]["cost"]
		if already_upgraded:
			damage_value.text   = "Damage: %d (Maxed)" % current_tower.damage
			firerate_value.text = "Pulse Rate: %.1fs (Maxed)" % current_tower.pulse_rate
			upgrade_btn.text     = "Maxed out"
			upgrade_btn.disabled = true
		else:
			damage_value.text   = "Damage: %d → %d" % [current_tower.damage, current_tower.damage + data["damage"]["amount"]]
			firerate_value.text = "Pulse Rate: %.1fs → %.1fs" % [current_tower.pulse_rate, current_tower.pulse_rate + data["pulse_rate"]["amount"]]
			upgrade_btn.text     = "Upgrade all  —  %d pts" % total_cost
			upgrade_btn.disabled = CurrencyManager.get_currency() < total_cost
	elif tower_name == "Swordfish":
		var data = UpgradeManager.upgrade_data["Swordfish"]
		var total_cost = data["damage"]["cost"] + data["charge_speed"]["cost"]
		if already_upgraded:
			damage_value.text   = "Damage: %d (Maxed)" % current_tower.damage_amount
			firerate_value.text = "Charge Speed: %.0f (Maxed)" % current_tower.charge_speed
			upgrade_btn.text     = "Maxed out"
			upgrade_btn.disabled = true
		else:
			damage_value.text   = "Damage: %d → %d" % [current_tower.damage_amount, current_tower.damage_amount + data["damage"]["amount"]]
			firerate_value.text = "Charge Speed: %.0f → %.0f" % [current_tower.charge_speed, current_tower.charge_speed + data["charge_speed"]["amount"]]
			upgrade_btn.disabled = CurrencyManager.get_currency() < total_cost
	else:
		var data = UpgradeManager.upgrade_data[tower_name]
		var total_cost = UpgradeManager.get_total_cost(tower_name)
		if already_upgraded:
			damage_value.text   = "Damage: %d (Maxed)" % current_tower.damage
			firerate_value.text = "Fire Rate: %.1fs (Maxed)" % current_tower.fire_rate
			upgrade_btn.text     = "Maxed out"
			upgrade_btn.disabled = true
		else:
			damage_value.text   = "Damage: %d → %d" % [current_tower.damage, current_tower.damage + data["damage"]["amount"]]
			firerate_value.text = "Fire Rate: %.1fs → %.1fs" % [current_tower.fire_rate, current_tower.fire_rate + data["fire_rate"]["amount"]]
			upgrade_btn.text     = "Upgrade all  —  %d pts" % total_cost
			upgrade_btn.disabled = CurrencyManager.get_currency() < total_cost

func _on_upgrade_pressed() -> void:
	print("Upgrade button pressed!")      
	print("Tower: ", tower_name)           
	print("Tower ref: ", current_tower)
	if tower_name == "Sawshark":
		if UpgradeManager.upgrade_sawshark(current_tower):
			refresh()
	elif tower_name == "Angler":
		if UpgradeManager.upgrade_angler(current_tower):
			refresh()
	elif tower_name == "Jellyfish":
		if UpgradeManager.upgrade_jellyfish(current_tower):
			refresh()
	elif tower_name == "Swordfish":
		if UpgradeManager.upgrade_swordfish(current_tower):
			refresh()
	else:
		if UpgradeManager.upgrade_all(current_tower, tower_name):
			refresh()

func _on_close_pressed() -> void:
	visible = false
	current_tower = null

func _on_currency_changed(_new_amount: int) -> void:
	if visible:
		refresh()
