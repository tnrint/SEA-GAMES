extends Node

var upgrade_data = {
	"Fish": {
		"damage":    { "cost": 150,  "amount": 40  },
		"fire_rate": { "cost": 200,  "amount": -0.2 },
	},
	"Ice Fish": {  
		"damage":    { "cost": 200,  "amount": 60  },
		"fire_rate": { "cost": 250, "amount": -0.2 },
	},
	"Shark":  {  
		"damage":    { "cost": 250,  "amount": 100  },
		"fire_rate": { "cost": 300, "amount": -0.2 },
	},
	"Jellyfish": {  
		"damage":    { "cost": 150,  "amount": 30  },
		"pulse_rate": { "cost": 300, "amount": -0.5 },
	},
	"Sawshark": {  
		"damage":    { "cost": 150,  "amount": 30  },
		"attack_duration": { "cost": 300, "amount": -1.0 },
	},
	"SwordFish": {  
		"damage":    { "cost": 300,  "amount": 50  },
		"charge_speed": { "cost": 300, "amount": 100.0 },
	},
	"Red Fish": {  
		"damage":    { "cost": 400,  "amount": 20  },
		"fire_rate": { "cost": 300, "amount": -0.2 },
	},
	"Angler": {  
		"speed_multiplier": { "cost": 250,  "amount": 0.5 },  
		"buff_range":       { "cost": 500,  "amount": 50  },  
	}
}

var upgraded_towers: Dictionary = {}

func get_tower_id(tower) -> String:
	return str(tower.get_instance_id())

func is_upgraded(tower) -> bool:
	return upgraded_towers.get(get_tower_id(tower), false)

func get_total_cost(tower_name: String) -> int:
	if not upgrade_data.has(tower_name):
		return 0
	var data = upgrade_data[tower_name]
	return data["damage"]["cost"] + data["fire_rate"]["cost"]

func upgrade_all(tower, tower_name: String) -> bool:
	if is_upgraded(tower):
		print("Already upgraded!")
		return false
	if not upgrade_data.has(tower_name):
		print("Tower not found: ", tower_name)
		return false
	var total = get_total_cost(tower_name)
	if not CurrencyManager.spend_currency(total):
		print("Not enough currency!")
		return false
	var data = upgrade_data[tower_name]
	tower.damage    += data["damage"]["amount"]
	tower.fire_rate += data["fire_rate"]["amount"]
	upgraded_towers[get_tower_id(tower)] = true
	print(tower_name, " fully upgraded!")
	return true

func upgrade_angler(tower) -> bool:
	if is_upgraded(tower):
		print("Already upgraded!")
		return false
	var total = upgrade_data["Angler"]["speed_multiplier"]["cost"] + upgrade_data["Angler"]["buff_range"]["cost"]
	if not CurrencyManager.spend_currency(total):
		print("Not enough currency!")
		return false
	# Apply upgrades
	tower.speed_multiplier += upgrade_data["Angler"]["speed_multiplier"]["amount"]
	var shape = tower.get_node("BuffRange/CollisionShape2D").shape
	shape.radius += upgrade_data["Angler"]["buff_range"]["amount"]
	upgraded_towers[get_tower_id(tower)] = true
	print("Angler upgraded!")
	return true

func upgrade_sawshark(tower) -> bool:
	if is_upgraded(tower):
		print("Already upgraded!")
		return false
	var data = upgrade_data["Sawshark"]
	var total = data["damage"]["cost"] + data["attack_duration"]["cost"]
	if not CurrencyManager.spend_currency(total):
		print("Not enough currency!")
		return false
	tower.damage          += data["damage"]["amount"]
	tower.attack_duration += data["attack_duration"]["amount"]
	upgraded_towers[get_tower_id(tower)] = true
	print("Sawshark upgraded!")
	return true

func upgrade_jellyfish(tower) -> bool:
	if is_upgraded(tower):
		print("Already upgraded!")
		return false
	var data = upgrade_data["Jellyfish"]
	var total = data["damage"]["cost"] + data["pulse_rate"]["cost"]
	if not CurrencyManager.spend_currency(total):
		print("Not enough currency!")
		return false
	tower.damage     += data["damage"]["amount"]
	tower.pulse_rate += data["pulse_rate"]["amount"]
	tower.pulse_timer.wait_time = tower.pulse_rate  
	upgraded_towers[get_tower_id(tower)] = true
	print("Jellyfish upgraded!")
	return true

func upgrade_swordfish(tower) -> bool:
	if is_upgraded(tower):
		print("Already upgraded!")
		return false
	var data = upgrade_data["Swordfish"]
	var total = data["damage"]["cost"] + data["charge_speed"]["cost"]
	if not CurrencyManager.spend_currency(total):
		print("Not enough currency!")
		return false
	tower.damage_amount  += data["damage"]["amount"]
	tower.charge_speed   += data["charge_speed"]["amount"]
	upgraded_towers[get_tower_id(tower)] = true
	print("Swordfish upgraded!")
	return true
