extends Area2D

# --- Tiers ---
const TIER_2_HP: int = 60  # full trash appearance
const TIER_1_HP: int = 30  # damaged appearance threshold

@export var max_hp: int = TIER_2_HP
var current_hp: int
var current_tier: int = 2

var path_follow: PathFollow2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func setup(new_path_follow: PathFollow2D):
	path_follow = new_path_follow

func _ready():
	current_hp = max_hp
	current_tier = 2
	update_appearance()

func _process(delta: float):
	path_follow.progress += 100 * delta

	if path_follow.progress_ratio >= 0.99:
		print("Trash reached end → damage player")
		queue_free()

func take_damage(amount: int):
	current_hp -= amount
	print("Trash HP:", current_hp)

	if current_tier == 2 and current_hp <= TIER_1_HP:
		transform_to_tier(1)

	if current_hp <= 0:
		die()

func transform_to_tier(tier: int):
	current_tier = tier
	update_appearance()
	print("Trash transformed to tier:", tier)

func update_appearance():
	match current_tier:
		2:
			if anim.sprite_frames.has_animation("tier2_walk"):
				anim.play("tier2_walk")
		1:
			if anim.sprite_frames.has_animation("tier1_walk"):
				anim.play("tier1_walk")

func die():
	print("Trash destroyed")
	queue_free()
