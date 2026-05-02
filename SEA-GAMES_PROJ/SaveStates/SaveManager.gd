extends Node

const PROFILES_FILE = "user://profiles.json"
var current_profile : String = ""

# Default game data template
func get_default_save():
	return {
		"level": 1,
		"coins": 0,
		"unlocked_words": []
	}

# ---------------------------
# PROFILE SYSTEM
# ---------------------------

func get_all_profiles() -> Array:
	if !FileAccess.file_exists(PROFILES_FILE):
		return []

	var file = FileAccess.open(PROFILES_FILE, FileAccess.READ)
	var text = file.get_as_text()

	var data = JSON.parse_string(text)

	# 🔐 make sure the file really contains an Array
	if typeof(data) != TYPE_ARRAY:
		return []

	return data

func save_profiles(profiles:Array):
	var file = FileAccess.open(PROFILES_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(profiles))

func create_profile(profile_name:String):
	var profiles = get_all_profiles()

	if profile_name in profiles:
		return false  # already exists

	profiles.append(profile_name)
	save_profiles(profiles)

	# create empty save file for that user
	save_game(profile_name, get_default_save())
	return true

func set_current_profile(profile_name:String):
	current_profile = profile_name


# ---------------------------
# SAVE / LOAD GAME DATA
# ---------------------------

func save_game(profile_name:String, data:Dictionary):
	var path = "user://save_%s.json" % profile_name
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))

func load_game(profile_name:String) -> Dictionary:
	var path = "user://save_%s.json" % profile_name
	
	if !FileAccess.file_exists(path):
		return get_default_save()

	var file = FileAccess.open(path, FileAccess.READ)
	return JSON.parse_string(file.get_as_text())

func delete_profile(profile_name:String):
	var profiles = get_all_profiles()

	if profile_name in profiles:
		profiles.erase(profile_name)
		save_profiles(profiles)

	# delete the save file
	var path = "user://save_%s.json" % profile_name
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		

func profile_exists(profile_name:String) -> bool:
	var profiles = get_all_profiles()
	return profile_name in profiles
