extends Node

var selected_characters: Array[CharacterData] = []

func clear_selection():
	selected_characters.clear()

func start_level(level_scene_path: String):
	get_tree().change_scene_to_file(level_scene_path)
