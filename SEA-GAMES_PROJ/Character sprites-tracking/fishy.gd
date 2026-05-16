extends Node2D

@export var damage: int = 25
@export var fire_rate: float = 0.5
@export var bubble_scene: PackedScene
@export var tower_name: String = "Fish"



var enemies_in_range: Array = []
var can_shoot: bool = true

@onready var sprite = $AnimatedSprite2D

func _ready():
	$Area2D.area_entered.connect(_on_area_entered)
	$Area2D.area_exited.connect(_on_area_exited)
	
	# --- FIX: START IDLE IMMEDIATELY ---
	if sprite.sprite_frames.has_animation("Idle"):
		sprite.play("Idle")

func _on_area_entered(area: Area2D):
	if area.has_method("take_damage"):
		enemies_in_range.append(area)

func _on_area_exited(area: Area2D):
	enemies_in_range.erase(area)

func _process(_delta):
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))

	if enemies_in_range.size() > 0 and can_shoot:
		var target = get_closest_enemy()
		# We use lerp_angle for smoother rotation so it doesn't snap
		var target_angle = (target.global_position - global_position).angle()
		rotation = lerp_angle(rotation, target_angle, 0.2)
		shoot(target)

func get_closest_enemy() -> Area2D:
	var closest = enemies_in_range[0]
	var min_dist = global_position.distance_to(closest.global_position)
	for enemy in enemies_in_range:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = enemy
	return closest

func shoot(target: Area2D):
	can_shoot = false
	SFXManager.play("fish_shoot")

	var bubble = bubble_scene.instantiate()
	get_tree().current_scene.add_child(bubble)
	bubble.global_position = global_position
	bubble.target = target
	bubble.damage = damage

	if sprite.sprite_frames.has_animation("Attack"):
		sprite.play("Attack")

	# Wait for the fire rate cooldown
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

	# --- FIX: GO BACK TO IDLE ---
	if sprite.sprite_frames.has_animation("Idle"):
		sprite.play("Idle")

# --- UNIVERSAL BUFF SYSTEM ---
var currently_buffed: bool = false
var original_fire_rate: float = 0.0

func add_buff(multiplier: float):
	if currently_buffed: return
	currently_buffed = true
	
	print(">>> [BUFFED] ", name, " shooting speed increased!")
	
	original_fire_rate = fire_rate
	fire_rate = original_fire_rate / multiplier

func remove_buff():
	if not currently_buffed: return
	currently_buffed = false
	
	print("<<< [BUFF EXPIRED] ", name, " reset.")
	fire_rate = original_fire_rate
	
func _unhandled_input(event) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var distance = global_position.distance_to(mouse_pos)
		if distance < 40:
			print("Tower clicked! Opening panel...")
			get_node("/root/UpgradePanel").show_panel(self, tower_name)
			get_viewport().set_input_as_handled()
