extends Area2D

@export var speed: float = 1200.0
@export var damage: int = 75 
@export var slow_multiplier: float = 0.4 
@export var slow_duration: float = 3.0

var direction: Vector2 = Vector2.ZERO

func _ready():
	# Make sure the bullet is listening to hits
	# If you haven't connected this in the editor, this line does it for you:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func _process(delta):
	global_position += direction * speed * delta

func _on_area_entered(area: Area2D):
	# DEBUG: This will show in your console if the bullet hits ANYTHING
	print("Bullet hit: ", area.name)
	
	if area.has_method("take_damage"):
		area.take_damage(damage)
		if area.has_method("apply_slow"):
			area.apply_slow(slow_multiplier, slow_duration)
		
		# Bullet disappears on hit
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
