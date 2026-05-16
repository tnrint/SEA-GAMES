# SFXManager.gd
extends Node

var sfx_player: AudioStreamPlayer

var sounds = {
	"enemy_hit": preload("res://Audio/attack sounds/SEAGAMES_HIT_cleaned.wav"),
	"fish_shoot": preload("res://Audio/attack sounds/pop.mp3"),
	"ice_fish_shoot": preload("res://Audio/attack sounds/ice_pop.mp3"),
	"shark_shoot": preload("res://Audio/attack sounds/boomerang throw.mp3"),
	"sword_fish_attack": preload("res://Audio/attack sounds/sword_fish.mp3"),
	"jelly_fish_elec": preload("res://Audio/attack sounds/jellyfixh.mp3"),
	"angler_buff": preload("res://Audio/attack sounds/angler_buff.mp3"),
	"redfish_shotgun": preload("res://Audio/attack sounds/shotgun_bubble.mp3"),
	"squid": preload("res://Audio/attack sounds/squid.mp3")
}

func _ready() -> void:
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)

func play(sfx_name: String) -> void:
	if sounds.has(sfx_name):
		sfx_player.stream = sounds[sfx_name]
		sfx_player.play()
	else:
		print("SFX not found: ", sfx_name)
