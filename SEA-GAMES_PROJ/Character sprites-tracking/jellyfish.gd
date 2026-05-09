extends Node2D

# --- Configuration ---
@export var damage: int = 15
@export var pulse_rate: float = 2.5
@export var shock_range: float = 120.0 
@export var slow_duration: float = 1.0
@export var vibrate_intensity: float = 3.0 

# --- Node References ---
@onready var pulse_timer = $PulseTimer
@onready var area = $Area2D
@onready var sprite = $AnimatedSprite2D
@onready var collision_shape = $Area2D/CollisionShape2D

var shock_ring: Line2D 
var is_electrocuting: bool = false
var current_target: Node2D = null
var can_shock: bool = true # Track if the jellyfish is ready to zap

func _ready():
	setup_visual_ring()
	
	if collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = shock_range
	
	# Connect the area signal so we know the MOMENT trash arrives
	area.area_entered.connect(_on_area_entered)
	
	pulse_timer.wait_time = pulse_rate
	pulse_timer.one_shot = true # We will handle the looping manually for better control
	pulse_timer.timeout.connect(_on_pulse_timeout)

func setup_visual_ring():
	shock_ring = Line2D.new()
	add_child(shock_ring)
	shock_ring.width = 3.0
	shock_ring.default_color = Color(0.4, 0.8, 1.0, 0.0) 
	
	var points = []
	for i in range(33):
		var angle = deg_to_rad(i * (360.0 / 32.0))
		points.append(Vector2(cos(angle), sin(angle)) * shock_range)
	shock_ring.points = points
	shock_ring.scale = Vector2.ZERO

func _process(_delta):
	update_target()
	
	if is_instance_valid(current_target):
		var angle_to_target = global_position.direction_to(current_target.global_position).angle()
		rotation = angle_to_target + PI/2 
	else:
		rotation = lerp_angle(rotation, 0, 0.1)

	if is_electrocuting:
		sprite.position.x = randf_range(-vibrate_intensity, vibrate_intensity)
		sprite.position.y = randf_range(-vibrate_intensity, vibrate_intensity)
	else:
		sprite.position = Vector2.ZERO

func update_target():
	var targets = area.get_overlapping_areas()
	if targets.size() > 0:
		current_target = targets[0]
	else:
		current_target = null

# --- NEW: Triggered the moment something enters ---
func _on_area_entered(_new_area):
	if can_shock and not is_electrocuting:
		execute_shock()

func _on_pulse_timeout():
	can_shock = true
	# If enemies are still here when cooldown ends, zap again!
	var targets = area.get_overlapping_areas()
	if targets.size() > 0:
		execute_shock()

func execute_shock():
	can_shock = false
	is_electrocuting = true
	
	if sprite.sprite_frames.has_animation("attack"):
		sprite.play("attack")
	
	animate_ring()
	
	var targets = area.get_overlapping_areas()
	for target in targets:
		if target.has_method("take_damage"):
			target.take_damage(damage)
			if target.has_method("apply_slow"):
				target.apply_slow(0.3, slow_duration)

	await get_tree().create_timer(0.6).timeout
	
	is_electrocuting = false
	if sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")
		
	# Start the cooldown timer AFTER the attack finishes
	pulse_timer.start()

func animate_ring():
	var tween = create_tween().set_parallel(true)
	shock_ring.scale = Vector2.ZERO
	shock_ring.modulate.a = 1.0
	
	tween.tween_property(shock_ring, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(shock_ring, "modulate:a", 0.0, 0.5).set_delay(0.1)
