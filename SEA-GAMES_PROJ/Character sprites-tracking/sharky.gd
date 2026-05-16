extends Node2D

@export var damage: int = 50
@export var fire_rate: float = 1.5
@export var projectile_scene: PackedScene 
@export var tower_name: String = "Shark"

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
	SFXManager.play("shark_shoot")
	if sprite.sprite_frames.has_animation("attack"):
		sprite.play("attack")
		# Using a simple timer to reset animation instead of complex signals
		get_tree().create_timer(0.5).timeout.connect(func(): sprite.play("idle"))

	var p = projectile_scene.instantiate()
	p.target = target_node
	p.launcher = self
	p.global_position = global_position
	get_tree().current_scene.add_child(p)
	
	# --- UNIVERSAL BUFF SYSTEM ---
var base_fire_rate: float = 0.0
var currently_buffed: bool = false

func add_buff(multiplier: float):
	if currently_buffed: return
	currently_buffed = true
	
	# 1. Show the visual effect
	# Assumes you added an AnimatedSprite2D named "BuffVisual" to the fish
	if has_node("BuffVisual"):
		get_node("BuffVisual").show()
		if get_node("BuffVisual").sprite_frames.has_animation("sparkle"):
			get_node("BuffVisual").play("sparkle")
	
	# 2. Speed up the firing Timer
	var timer = get_node_or_null("Timer")
	if timer:
		base_fire_rate = timer.wait_time
		timer.wait_time = base_fire_rate / multiplier

func remove_buff():
	if not currently_buffed: return
	currently_buffed = false
	
	# 1. Hide the visual effect
	if has_node("BuffVisual"):
		get_node("BuffVisual").hide()
		get_node("BuffVisual").stop()
	
	# 2. Reset the Timer
	var timer = get_node_or_null("Timer")
	if timer and base_fire_rate > 0:
		timer.wait_time = base_fire_rate

func _unhandled_input(event) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var distance = global_position.distance_to(mouse_pos)
		if distance < 40:
			get_node("/root/UpgradePanel").show_panel(self, tower_name)
			get_viewport().set_input_as_handled()
