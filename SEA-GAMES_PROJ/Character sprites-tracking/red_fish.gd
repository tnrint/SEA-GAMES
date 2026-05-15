extends Node2D

@export_group("Stats")
@export var damage: int = 15
@export var fire_rate: float = 0.8
@export var spread_angle: float = 12.0 # Tight spread for shotgun feel

@export_group("Setup")
@export var bullet_scene: PackedScene 

var enemies_in_range: Array = []
var can_shoot: bool = true

@onready var sprite = $AnimatedSprite2D
@onready var buff_visual = $BuffVisual

func _ready():
	# Connect signals for enemy detection
	$DetectionRange.area_entered.connect(_on_area_entered)
	$DetectionRange.area_exited.connect(_on_area_exited)
	sprite.play("Idle")

func _on_area_entered(area: Area2D):
	if area.has_method("take_damage"):
		enemies_in_range.append(area)

func _on_area_exited(area: Area2D):
	enemies_in_range.erase(area)

func _process(_delta):
	# Remove dead enemies from list
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))

	if enemies_in_range.size() > 0:
		var target = enemies_in_range[0]
		
		# POINT AT ENEMY
		look_at(target.global_position)
		
		# ANTI-FLIP LOGIC: Keep the fish from being upside down
		# If rotation is between 90 and 270 degrees (facing left)
		if abs(rotation_degrees) > 90:
			sprite.flip_v = true
		else:
			sprite.flip_v = false
		
		# SHOOT IF COOLDOWN IS READY
		if can_shoot:
			shoot()

func shoot():
	can_shoot = false
	
	if sprite.sprite_frames.has_animation("Attack"):
		sprite.play("Attack")

	# RECOIL EFFECT: Push fish back slightly
	var original_pos = sprite.position
	sprite.position -= Vector2.RIGHT.rotated(rotation) * 8

	# SPAWN 3 BULLETS
	for i in range(-1, 2):
		var b = bullet_scene.instantiate()
		get_tree().current_scene.add_child(b)
		b.global_position = global_position
		
		var shot_rotation = rotation + deg_to_rad(i * spread_angle)
		b.direction = Vector2.RIGHT.rotated(shot_rotation)
		b.rotation = shot_rotation
		
		# Transfer damage stat to bullet
		if "max_damage" in b:
			b.max_damage = damage

	# Recover from recoil
	await get_tree().create_timer(0.1).timeout
	sprite.position = original_pos

	# Fire rate cooldown
	await get_tree().create_timer(fire_rate).timeout
	
	can_shoot = true
	sprite.play("Idle")

# --- UNIVERSAL BUFF SYSTEM (Angler Fish Support) ---
var currently_buffed: bool = false
var original_fire_rate: float = 0.0

func add_buff(multiplier: float):
	if currently_buffed: return
	currently_buffed = true
	
	print(">>> [BUFFED] ", name, " shotgun speed boosted!")
	if buff_visual: 
		buff_visual.show()
		buff_visual.play("default")
	
	original_fire_rate = fire_rate
	fire_rate = original_fire_rate / multiplier

func remove_buff():
	if not currently_buffed: return
	currently_buffed = false
	
	print("<<< [BUFF EXPIRED] ", name, " reset.")
	if buff_visual: 
		buff_visual.hide()
	
	fire_rate = original_fire_rate
