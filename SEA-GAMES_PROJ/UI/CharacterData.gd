extends Resource
class_name CharacterData

@export var character_name: String = ""
@export var cost: int = 0
@export var icon: Texture2D
@export var scene_path: String = ""

func _init(name: String = "", c: int = 0, i: Texture2D = null, path: String = ""):
	character_name = name
	cost = c
	icon = i
	scene_path = path
