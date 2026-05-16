extends Node2D

@export_group("Buff Settings")
@export var speed_multiplier: float = 1.5 
@export var tower_name: String = "Angler"

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
