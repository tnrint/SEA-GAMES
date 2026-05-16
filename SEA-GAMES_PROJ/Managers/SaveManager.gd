extends Node

const PROFILES_FILE = "user://profiles.json"
const SAVE_PATH_TEMPLATE = "user://save_%s.json"

var current_profile: String = ""

# =====================================================
# SAFETY
# =====================================================

func _validate_profile() -> bool:
	if current_profile == "":
		push_error("SaveManager: current_profile is EMPTY!")
		return false
	return true


# =====================================================
# DEFAULT SAVE DATA
# =====================================================

func get_default_save() -> Dictionary:
	return {
		"unlocked_level": 1,
		"last_played_level": 1
	}


# =====================================================
# PROFILE SYSTEM
# =====================================================

func get_all_profiles() -> Array:
	if !FileAccess.file_exists(PROFILES_FILE):
		return []

	var file = FileAccess.open(PROFILES_FILE, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())

	if typeof(data) != TYPE_ARRAY:
		return []

	return data


func save_profiles(profiles: Array) -> void:
	var file = FileAccess.open(PROFILES_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(profiles))


func create_profile(profile_name: String) -> bool:
	var profiles = get_all_profiles()

	if profile_name in profiles:
		return false

	profiles.append(profile_name)
	save_profiles(profiles)

	save_game(profile_name, get_default_save())
	return true


func delete_profile(profile_name: String) -> void:
	var profiles = get_all_profiles()

	if profile_name in profiles:
		profiles.erase(profile_name)
		save_profiles(profiles)

	var path = SAVE_PATH_TEMPLATE % profile_name
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func profile_exists(profile_name: String) -> bool:
	return profile_name in get_all_profiles()


func set_current_profile(profile_name: String) -> void:
	current_profile = profile_name
	print("Profile set to:", current_profile)


func get_current_profile() -> String:
	return current_profile


# =====================================================
# SAVE / LOAD GAME
# =====================================================

func save_game(profile_name: String, data: Dictionary) -> void:
	var path = SAVE_PATH_TEMPLATE % profile_name
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))


func load_game(profile_name: String) -> Dictionary:
	var path = SAVE_PATH_TEMPLATE % profile_name

	if !FileAccess.file_exists(path):
		return get_default_save()

	var file = FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())

	if typeof(data) != TYPE_DICTIONARY:
		return get_default_save()

	return data


# =====================================================
# PROGRESSION SYSTEM
# =====================================================

func get_unlocked_level() -> int:
	if !_validate_profile():
		return 1

	var save = load_game(current_profile)
	return save.get("unlocked_level", 1)


func get_last_played_level() -> int:
	if !_validate_profile():
		return 1

	var save = load_game(current_profile)
	return save.get("last_played_level", 1)


func set_last_played_level(level: int) -> void:
	if !_validate_profile():
		return

	var save = load_game(current_profile)
	save["last_played_level"] = level
	save_game(current_profile, save)


func unlock_next_level(completed_level: int) -> void:
	if !_validate_profile():
		return

	var save = load_game(current_profile)

	# Only increase progression if needed
	save["unlocked_level"] = max(
		save.get("unlocked_level", 1),
		completed_level + 1
	)

	save["last_played_level"] = completed_level + 1

	save_game(current_profile, save)

	print("SAVE UPDATED:", save)
