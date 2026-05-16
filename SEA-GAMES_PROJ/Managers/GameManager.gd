extends Node

var selected_characters: Array[CharacterData] = []

# Ordered campaign levels
var level_scenes := [
	"res://Maps/area_1_1.tscn",
	"res://Maps/area_1_2.tscn",
	"res://Maps/area_1_3.tscn",
	"res://Maps/area_2_1.tscn",
	"res://Maps/area_2_2.tscn",
	"res://Maps/area_2_3.tscn",
	"res://Maps/area_3_1.tscn",
	"res://Maps/area_3_2.tscn",
    "res://Maps/area_3_3.tscn"
]

# =====================================================
# CHARACTER SYSTEM
# =====================================================
func clear_selection():
	selected_characters.clear()

# =====================================================
# LEVEL RESOLUTION
# =====================================================
func get_level_scene_path(level: int) -> String:
	level = clamp(level, 1, level_scenes.size())
	return level_scenes[level - 1]

# =====================================================
# START LEVEL SYSTEM
# =====================================================
func start_current_level():
	var level = SaveManager.get_last_played_level()
	start_level(level)

func start_level(level: int):
	CurrencyManager.reset_for_new_level(200)   # Reset currency
	print("Starting level:", level)
	get_tree().change_scene_to_file(get_level_scene_path(level))

# =====================================================
# LEVEL COMPLETION
# =====================================================
func level_completed(current_level: int):
	print("🔥 LEVEL COMPLETE:", current_level)
	
	SaveManager.unlock_next_level(current_level)
	
	# Reset resources before going to character select
	CurrencyManager.reset_for_new_level(200)
	
	# move to character select
	get_tree().change_scene_to_file("res://UI/CharacterSelect.tscn")
