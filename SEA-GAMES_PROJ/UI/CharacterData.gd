class_name CharacterData
extends Resource

@export var name: String = "Character"
@export var cost: int = 50
@export var icon: Texture2D

# NEW: Path to the actual character scene (fishy.tscn, etc.)
@export_file("*.tscn") var scene_path: String = ""

func _init(p_name: String = "", p_cost: int = 50, p_icon: Texture2D = null, p_scene_path: String = ""):
	name = p_name
	cost = p_cost
	icon = p_icon
	scene_path = p_scene_path
