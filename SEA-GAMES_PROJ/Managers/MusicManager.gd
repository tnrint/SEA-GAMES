# MusicManager.gd
extends Node

var audio_player: AudioStreamPlayer

var area_music = {
	0: preload("res://Audio/Map Audio/MainMenu.mp3"),
	1: preload("res://Audio/Map Audio/Area1.mp3"),
	2: preload("res://Audio/Map Audio/Area2.mp3"),
	3: preload("res://Audio/Map Audio/Area3.mp3"),
}

var current_area: int = -1

func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.volume_db = 0.0
	get_tree().node_added.connect(_on_node_added)
	
	# Fallback for the very first scene
	await get_tree().process_frame
	var root = get_tree().current_scene
	if root and root.has_meta("area"):
		print("First scene area: ", root.get_meta("area"))
		play_music_for_area(root.get_meta("area"))
	else:
		print("No area metadata on first scene!")

func _on_node_added(node: Node) -> void:
	if node.get_parent() != get_tree().root:
		return
	await get_tree().process_frame
	var root = get_tree().current_scene
	if root and root.has_meta("area"):
		print("Area found: ", root.get_meta("area"))
		play_music_for_area(root.get_meta("area"))
	else:
		print("No area metadata found!")

func play_music_for_area(area: int) -> void:
	if area == current_area:
		print("Same area, keeping music")
		return
	current_area = area
	audio_player.stream = area_music[area]
	audio_player.play()
	print("Now playing music for area: ", area)

func stop_music() -> void:
	audio_player.stop()
	current_area = -1
