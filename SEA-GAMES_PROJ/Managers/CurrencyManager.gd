# CurrencyManager.gd
extends Node

signal currency_changed(new_amount: int)

var currency: int = 200  # matches your starting points in gc.gd

func add_currency_from_damage(damage_dealt: int) -> void:
	var earned = int(damage_dealt * 0.2)  # 10% of damage = currency earned
	if earned > 0:
		currency += earned
		emit_signal("currency_changed", currency)

func spend_currency(amount: int) -> bool:
	if currency >= amount:
		currency -= amount
		emit_signal("currency_changed", currency)
		return true
	return false  # not enough currency

func get_currency() -> int:
	return currency
