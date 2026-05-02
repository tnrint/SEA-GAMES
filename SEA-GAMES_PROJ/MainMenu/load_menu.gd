extends Control

@onready var users_container = $VBoxContainer/ScrollContainer/Users
@onready var create_btn = $VBoxContainer/CreateProfile
@onready var back_btn = $VBoxContainer/Back
@onready var name_input = $VBoxContainer/ProfileNameInput
@onready var scroll_container: ScrollContainer = $VBoxContainer/ScrollContainer


func _ready():
	create_btn.pressed.connect(_on_create_profile_pressed)
	refresh_profiles()


# =============================
# CREATE PROFILE (CUSTOM NAME)
# =============================
func _on_create_profile_pressed():
	var name = name_input.text.strip_edges()

	if name == "":
		print("Enter a profile name")
		return

	if SaveManager.profile_exists(name):
		print("Profile already exists")
		return

	SaveManager.create_profile(name)
	name_input.text = ""
	refresh_profiles()


# =============================
# SHOW PROFILE BUTTONS + DELETE
# =============================
func refresh_profiles():
	for child in users_container.get_children():
		child.queue_free()

	var profiles = SaveManager.get_all_profiles()

	if profiles.is_empty():
		var label = Label.new()
		label.text = "No profiles yet"
		users_container.add_child(label)
		return

	for profile in profiles:
		# container row
		var row = HBoxContainer.new()

		# PLAY BUTTON
		var play_btn = Button.new()
		play_btn.text = profile
		play_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		play_btn.pressed.connect(_on_profile_selected.bind(profile))

		# DELETE BUTTON
		var delete_btn = Button.new()
		delete_btn.text = "X"
		delete_btn.custom_minimum_size = Vector2(40, 40)
		delete_btn.pressed.connect(_on_delete_profile.bind(profile))

		row.add_child(play_btn)
		row.add_child(delete_btn)
		users_container.add_child(row)
		await get_tree().process_frame          # Wait one frame
		scroll_container.scroll_vertical = 0

func _on_profile_selected(profile_name):
	SaveManager.set_current_profile(profile_name)
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_delete_profile(profile_name):
	print("Deleting profile:", profile_name)
	SaveManager.delete_profile(profile_name)
	refresh_profiles()


func _on_back_pressed():
	get_tree().change_scene_to_file("res://MainMenu/main_menu.tscn")
