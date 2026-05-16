# CurrencyManager.gd
extends Node

signal currency_changed(new_amount: int)

var currency: int = 200

# Reset currency for a new level
func reset_for_new_level(starting_amount: int = 200) -> void:
	currency = starting_amount
	emit_signal("currency_changed", currency)
	print("💰 Currency reset to ", currency, " for new level")


func add_currency_from_damage(damage_dealt: int) -> void:
	var earned = int(damage_dealt * 0.2)
	if earned > 0:
		currency += earned
		emit_signal("currency_changed", currency)


func spend_currency(amount: int) -> bool:
	if currency >= amount:
		currency -= amount
		emit_signal("currency_changed", currency)
		return true
	return false


func get_currency() -> int:
	return currency
