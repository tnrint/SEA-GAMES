extends Area2D

@export var speed: float = 350.0

var target: Area2D = null
var damage: int = 0
var _hit: bool = false

func _ready():
	area_entered.connect(_on_area_entered)
	if $AnimatedSprite2D.sprite_frames.has_animation("icebubble"):
		$AnimatedSprite2D.play("icebubble")

func _physics_process(delta):
	if not is_instance_valid(target):
		queue_free()
		return

	var direction = (target.global_position - global_position).normalized()
	global_position += direction * speed * delta

func _on_area_entered(area: Area2D):
	if _hit:
		return
	if area == target or area.has_method("take_damage"):
		explode(area)

func explode(area: Area2D):
	_hit = true

	if area.has_method("take_damage"):
		area.take_damage(damage)
		print("Bubble hit enemy for:", damage)

	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)

	if $AnimatedSprite2D.sprite_frames.has_animation("icepop"):
		$AnimatedSprite2D.play("icepop")
		# Connect to the signal directly instead of awaiting
		$AnimatedSprite2D.animation_finished.connect(_on_pop_finished, CONNECT_ONE_SHOT)
		# Safety net — force free if signal never fires
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(self):
			queue_free()
	else:
		await get_tree().create_timer(0.01).timeout
		queue_free()

func _on_pop_finished():
	queue_free()
