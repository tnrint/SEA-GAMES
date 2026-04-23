extends Node2D

var enemy_scene = preload("res://Enemies/trash_1.tscn")

func _ready() -> void:
	var follow_path = PathFollow2D.new()
	var enemy = enemy_scene.instantiate()
	enemy.setup(follow_path)
	follow_path.add_child(enemy)
	$Path2D.add_child(follow_path)
