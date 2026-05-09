extends Node2D

@export var damage: int = 50
@export var fire_rate: float = 1.5
@export var projectile_scene: PackedScene 

@onready var sprite = $AnimatedSprite2D
@onready var range_area = $Area2D

var current_target: Node2D = null

func _ready():
	# Start idle
	if sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")
	
	# Basic Timer
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = fire_rate
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _process(_delta: float):
	# 1. FIND TARGET
	var targets = range_area.get_overlapping_areas()
	var enemies = targets.filter(func(a): return a.has_method("take_damage"))
	
	if enemies.size() > 0:
		current_target = enemies[0]
	else:
		current_target = null

	# 2. TRACK TARGET
	if is_instance_valid(current_target):
		# This forces the tower to face the enemy instantly
		look_at(current_target.global_position)
		# NOTE: If the shark is sideways after this, add this line:
		# rotation += deg_to_rad(90) 
	else:
		# If no enemy, look "Up" (default)
		rotation = lerp_angle(rotation, 0, 0.1)
		if sprite.animation != "idle":
			sprite.play("idle")

func _on_timer_timeout():
	if is_instance_valid(current_target):
		fire_projectile(current_target)

func fire_projectile(target_node):
	if projectile_scene == null: return
	
	if sprite.sprite_frames.has_animation("attack"):
		sprite.play("attack")
		# Using a simple timer to reset animation instead of complex signals
		get_tree().create_timer(0.5).timeout.connect(func(): sprite.play("idle"))

	var p = projectile_scene.instantiate()
	p.target = target_node
	p.launcher = self
	p.global_position = global_position
	get_tree().current_scene.add_child(p)
