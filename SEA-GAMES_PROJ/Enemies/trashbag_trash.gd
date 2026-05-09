extends Area2D

# --- Tiers ---
const TIER_2_HP: int = 60
const TIER_1_HP: int = 30

@export var max_hp: int = TIER_2_HP
var current_hp: int
var current_tier: int = 2
var speed_multiplier: float = 1.0 

var path_follow: PathFollow2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func setup(new_path_follow: PathFollow2D):
	path_follow = new_path_follow

func _ready():
	current_hp = max_hp
	current_tier = 2
	update_appearance()

func _process(delta: float):
	if path_follow:
		path_follow.progress += (100 * speed_multiplier) * delta
		if path_follow.progress_ratio >= 0.99:
			queue_free()

func apply_slow(multiplier: float, duration: float):
	speed_multiplier = multiplier
	await get_tree().create_timer(duration).timeout
	speed_multiplier = 1.0

func take_damage(amount: int):
	current_hp -= amount
	if current_tier == 2 and current_hp <= TIER_1_HP:
		transform_to_tier(1)
	if current_hp <= 0:
		die()

func transform_to_tier(tier: int):
	current_tier = tier
	update_appearance()

func update_appearance():
	match current_tier:
		2:
			if anim.sprite_frames.has_animation("tier2_walk"):
				anim.play("tier2_walk")
		1:
			if anim.sprite_frames.has_animation("tier1_walk"):
				anim.play("tier1_walk")

func die():
	queue_free()
