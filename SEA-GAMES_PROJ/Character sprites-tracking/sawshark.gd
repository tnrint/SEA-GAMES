extends Area2D

@export var tower_name: String = "Sawshark"

# --- Configuration ---
@export var damage: int = 30
@export var attack_duration: float = 2.0
@export var cooldown_time: float = 4.0
@export var damage_tick_rate: float = 0.4
@export var vibrate_intensity: float = 2.0

# --- Node References ---
@onready var sprite = $AnimatedSprite2D
@onready var cooldown_timer = $CooldownTimer

# --- Internal Variables ---
var is_ready: bool = true
var is_attacking: bool = false
var targets_in_range = []
var current_target = null

func _ready():
	sprite.play("hidden")
	self.modulate.a = 0.5
	
	# Connect detection signals
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	# Setup Timer
	if cooldown_timer:
		cooldown_timer.wait_time = cooldown_time
		cooldown_timer.one_shot = true
		cooldown_timer.timeout.connect(_on_cooldown_finished)

func _process(_delta):
	if is_attacking:
		# 1. TRACKING: Rotate to look at the first target in line
		update_target()
		if is_instance_valid(current_target):
			look_at(current_target.global_position)
		
		# 2. VIBRATION: Shake the sprite
		sprite.position.x = randf_range(-vibrate_intensity, vibrate_intensity)
		sprite.position.y = randf_range(-vibrate_intensity, vibrate_intensity)
	else:
		# Reset position and keep rotation flat when resting
		sprite.position = Vector2.ZERO
		rotation = 0 

# --- Combat Logic ---

func update_target():
	# If current target is gone, grab the next one in the list
	if not is_instance_valid(current_target) or not current_target in targets_in_range:
		if targets_in_range.size() > 0:
			current_target = targets_in_range[0]
		else:
			current_target = null

func start_attack():
	if not is_ready: return
	
	is_ready = false
	is_attacking = true
	sprite.play("attack")
	self.modulate.a = 1.0
	
	var elapsed = 0.0
	while elapsed < attack_duration:
		deal_damage_to_all()
		await get_tree().create_timer(damage_tick_rate).timeout 
		elapsed += damage_tick_rate
	
	stop_attack()

func deal_damage_to_all():
	# Loop through and hit everything touching the saw
	for target in targets_in_range:
		if is_instance_valid(target) and target.has_method("take_damage"):
			target.take_damage(damage)

func stop_attack():
	is_attacking = false
	current_target = null
	sprite.play("hidden")
	self.modulate.a = 0.5 
	if cooldown_timer:
		cooldown_timer.start()

# --- Signal Handlers ---

func _on_area_entered(area):
	if area.has_method("take_damage"):
		if not area in targets_in_range:
			targets_in_range.append(area)
		
		if is_ready:
			start_attack()

func _on_area_exited(area):
	if area in targets_in_range:
		targets_in_range.erase(area)
	if area == current_target:
		current_target = null

func _on_cooldown_finished():
	is_ready = true
	if targets_in_range.size() > 0:
		start_attack()
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
