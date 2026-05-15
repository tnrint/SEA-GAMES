extends Node

var selected_characters : Array[CharacterData] = []
const MAX_SELECTION := 5

func add_character(char_data: CharacterData) -> bool:
	if selected_characters.size() >= MAX_SELECTION:
		return false
	
	if char_data in selected_characters:
		return false
	
	selected_characters.append(char_data)
	return true

func remove_character(char_data: CharacterData) -> void:
	selected_characters.erase(char_data)

func clear_selection() -> void:
	selected_characters.clear()
