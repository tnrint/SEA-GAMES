extends Node2D

@export_group("Stats")
@export var fire_rate: float = 2.5 
@export var range_radius: float = 800.0 

@export_group("Setup")
@export var bullet_scene: PackedScene 

var enemies_in_range: Array = []
var can_shoot: bool = true

@onready var sprite = $AnimatedSprite2D
@onready var buff_visual = find_child("BuffVisual")
@onready var detection_range = find_child("DetectionRange")

func _ready():
	if detection_range:
		detection_range.area_entered.connect(_on_area_entered)
		detection_range.area_exited.connect(_on_area_exited)
		
		var shape_node = detection_range.get_child(0)
		if shape_node and shape_node.shape is CircleShape2D:
			shape_node.shape.radius = range_radius
	
	# Start with idle animation
	sprite.play("idle")

func _on_area_entered(area: Area2D):
	if area.has_method("take_damage"):
		enemies_in_range.append(area)

func _on_area_exited(area: Area2D):
	enemies_in_range.erase(area)

func _process(_delta):
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))

	if enemies_in_range.size() > 0:
		var target = enemies_in_range[0]
		look_at(target.global_position)
		
		if abs(rotation_degrees) > 90:
			sprite.flip_v = true
		else:
			sprite.flip_v = false
		
		if can_shoot:
			shoot()
	else:
		# If no enemies are nearby and we aren't mid-attack, play idle
		if sprite.animation != "attack":
			sprite.play("idle")

func shoot():
	if not bullet_scene: return
	
	can_shoot = false
	
	# Play Attack animation
	sprite.play("attack")

	var b = bullet_scene.instantiate()
	get_tree().current_scene.add_child(b)
	b.global_position = global_position
	b.direction = Vector2.RIGHT.rotated(rotation)
	b.rotation = rotation

	# Wait for cooldown
	await get_tree().create_timer(fire_rate).timeout
	
	can_shoot = true
	
	# Switch back to idle after shooting if no one is in range
	if enemies_in_range.size() == 0:
		sprite.play("idle")
