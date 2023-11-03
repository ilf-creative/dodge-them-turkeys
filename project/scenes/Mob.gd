extends RigidBody2D

@export var min_speed = 150
@export var max_speed = 250
@export var has_hat = false

var screen_size

func take_hat():
	has_hat = true
	linear_velocity *= Vector2(1.5,1.5)

func _ready():
	screen_size = get_viewport_rect().size
	$AnimatedSprite2D.animation = "fly"
	await get_tree().create_timer(10).timeout
	queue_free()


func _process(_delta):
	var abs_degrees = abs(rotation_degrees)
	$AnimatedSprite2D.flip_v = (abs_degrees > 90 && abs_degrees < 270)
	$AnimatedSprite2D.animation = "flyhat" if has_hat else "fly"
	if has_hat:
		linear_velocity *= Vector2(1.01,1.01)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
