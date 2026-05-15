extends Node2D

var data: CharacterData

func setup(char_data: CharacterData) -> void:
	data = char_data
	
	if data.scene_path and ResourceLoader.exists(data.scene_path):
		var character_scene = load(data.scene_path)
		var instance = character_scene.instantiate()
		add_child(instance)
	else:
		push_error("Character scene not found: " + data.scene_path)
