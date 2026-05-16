extends CharacterBody2D

@export var charge_speed: float = 500.0
@export var return_speed: float = 200.0
@export var damage_amount: int = 20
@export var attack_cooldown: float = 0.6 # Time to wait at home before next hit

enum { IDLE, CHARGING, RETURNING, COOLDOWN }
var state = IDLE

var target_node = null
var home_pos = Vector2.ZERO
var can_charge: bool = true

# This helps the fish look at the right direction
@onready var sprite = $AnimatedSprite2D

func _ready():
	home_pos = global_position
	sprite.play("idle") 

func _physics_process(delta):
	match state:
		IDLE:
			rotation_degrees = lerp_angle(rotation, 0, 0.1)
			sprite.flip_v = false
			# Only find trash if the cooldown is over
			if can_charge:
				find_trash()
			
		CHARGING:
			if is_instance_valid(target_node):
				var dir = (target_node.global_position - global_position).normalized()
				velocity = dir * charge_speed
				look_at(target_node.global_position)
				sprite.flip_v = abs(rotation_degrees) > 90
				
				var collision = move_and_collide(velocity * delta)
				SFXManager.play("sword_fish_attack")
				if global_position.distance_to(target_node.global_position) < 25:
					hit_trash()
			else:
				state = RETURNING
				
		RETURNING:
			var dir = (home_pos - global_position).normalized()
			velocity = dir * return_speed
			look_at(home_pos)
			sprite.flip_v = abs(rotation_degrees) > 90
			
			move_and_slide()
			
			if global_position.distance_to(home_pos) < 5:
				global_position = home_pos # Snap to exact home
				velocity = Vector2.ZERO
				start_cooldown()

func find_trash():
	var areas = $DetectionRange.get_overlapping_areas()
	for area in areas:
		if area.has_method("take_damage"):
			target_node = area
			state = CHARGING
			break

func hit_trash():
	if is_instance_valid(target_node) and target_node.has_method("take_damage"):
		target_node.take_damage(damage_amount)
		CurrencyManager.add_currency_from_damage(damage_amount)
	state = RETURNING

func start_cooldown():
	state = IDLE # Visual state is idle
	can_charge = false
	# Wait for the cooldown period before allowing another charge
	await get_tree().create_timer(attack_cooldown).timeout
	can_charge = true

# --- UNIVERSAL BUFF SYSTEM (Modified for Swordfish) ---
var currently_buffed: bool = false
var original_charge_speed: float

func add_buff(multiplier: float):
	if currently_buffed: return
	currently_buffed = true
	
	if has_node("BuffVisual"):
		get_node("BuffVisual").show()
		get_node("BuffVisual").play("sparkle")
	
	# For Swordfish, buffing increases his dash speed!
	original_charge_speed = charge_speed
	charge_speed = original_charge_speed * multiplier

func remove_buff():
	if not currently_buffed: return
	currently_buffed = false
	
	if has_node("BuffVisual"):
		get_node("BuffVisual").hide()
	
	# Reset speed
	charge_speed = original_charge_speed
