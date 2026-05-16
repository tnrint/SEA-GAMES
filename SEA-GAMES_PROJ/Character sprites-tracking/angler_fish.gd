extends Node2D

@export_group("Buff Settings")
@export var speed_multiplier: float = 1.5 
@export var tower_name: String = "Angler"

@export_group("Range Circle Display")
# Adjust this value in the inspector to match the visual radius size of your BuffRange!
@export var visual_circle_radius: float = 75.0
# Warm light yellow profile: Red 1.0, Green 0.9, Blue 0.4, Alpha/Opacity 0.25 (25% visible)
@export var circle_color: Color = Color(1.0, 0.9, 0.4, 0.25)
@export var circle_line_width: float = 3.0

@onready var buff_range_area = $BuffRange
@onready var anim = $AnimatedSprite2D
@onready var radius_visual = $RadiusVisual # The new aura node

func _ready():
	# Connect signals
	buff_range_area.area_entered.connect(_on_area_entered)
	buff_range_area.area_exited.connect(_on_area_exited)
	
	# Start the animations
	if anim.sprite_frames.has_animation("idle"):
		anim.play("idle")
	
	if radius_visual:
		radius_visual.play("default") # Keep the radius glowing
		radius_visual.show()
		
	# Force Godot to call the _draw() loop to display our light ring right away
	queue_redraw()

# =====================================================
# WARM LIGHT CIRCLE RENDERING ENGINE
# =====================================================
func _draw() -> void:
	# Draws a clean, smooth vector circle border resembling a light field aura
	draw_arc(
		Vector2.ZERO,           # Center point relative to Angler's position
		visual_circle_radius,   # Size of the buff area display
		0.0,                    # Start angle
		TAU,                    # Full circle angle sweep (360 degrees in radians)
		64,                     # Smoothness detail steps
		circle_color,           # Warm light yellow color settings
		circle_line_width,      # Line thickness in pixels
		true                    # Smooth out pixel edges
	)

func _on_area_entered(area: Area2D):
	var fish = area.get_parent()
	if fish.has_method("add_buff"):
		SFXManager.play("angler_buff")
		# Terminal Output for confirmation
		print(">>> [BUFF ACTIVATED] Target: ", fish.name, " | Speed x", speed_multiplier)
		
		fish.add_buff(speed_multiplier)
		
		# Visual flare on the Angler himself
		if anim.sprite_frames.has_animation("buff"):
			anim.play("buff")
			get_tree().create_timer(0.5).timeout.connect(func(): anim.play("idle"))

func _on_area_exited(area: Area2D):
	var fish = area.get_parent()
	if fish.has_method("remove_buff"):
		# Terminal Output for confirmation
		print("<<< [BUFF EXPIRED] Target: ", fish.name, " | Reset to Normal")
		
		fish.remove_buff()

func _unhandled_input(event) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var distance = global_position.distance_to(mouse_pos)
		if distance < 40:
			get_node("/root/UpgradePanel").show_panel(self, tower_name)
			get_viewport().set_input_as_handled()
