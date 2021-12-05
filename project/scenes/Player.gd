extends Area2D
signal hit
signal gifted

const SCREEN_BUFFER_TOP = 60

export var speed = 400
export var hats = 1

var screen_size
var target = Vector2.ZERO
var oldTarget = Vector2.ZERO


func start(pos, start_hats = 1):
	position = pos
	hats = start_hats
	$AnimatedSprite.animation = _get_hat_name("down")
	$CollisionShape2D.disabled = false
	target = Vector2.ZERO
	oldTarget = Vector2.ZERO
	show()

func _ready():
	screen_size = get_viewport_rect().size
	hide()

func _process(delta):
	var velocity = Vector2() 
	
	# keyboard control
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	
	# touch control
	if (target != Vector2.ZERO && velocity.length() == 0): 
		var distance = (target - position)
		if (distance.length() > 20):
			velocity = (target - position).normalized()
			$AnimatedSprite.play()
		else:
			$AnimatedSprite.stop()
			velocity = Vector2.ZERO
			position = target
			target = Vector2.ZERO
	else:
		target = Vector2.ZERO

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
		
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, SCREEN_BUFFER_TOP, screen_size.y)
	var angle = abs(rad2deg(velocity.angle()))
	var isUpDownAngle = angle > 60 and angle < 120

	if velocity.x != 0 and !isUpDownAngle:
		$AnimatedSprite.animation = _get_hat_name("right")
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.y != 0 or isUpDownAngle:
		$AnimatedSprite.animation = _get_hat_name("down") if velocity.y > 0 else _get_hat_name("up")

func _get_hat_name(direction):
	var hat_prefix = str(clamp(hats, 0, 3)) + "h_"
	return hat_prefix + direction
	
func _on_Player_body_entered(body):
	if body.is_in_group("mobs"):
		if body.has_hat:
			hats += 1
			body.has_hat = false
			$AnimatedSprite.animation = _get_hat_name($AnimatedSprite.animation.split('_')[1])
		elif hats < 1:
			hide()
			emit_signal("hit")
			$CollisionShape2D.set_deferred("disabled", true)
		else:
			hats -= 1
			body.take_hat()
			$AnimatedSprite.animation = _get_hat_name($AnimatedSprite.animation.split('_')[1])
			
	elif body.is_in_group("gifts"):
		emit_signal("gifted")
		body.queue_free()
	

func _input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.is_pressed():
			var x = event.position.x
			var y = event.position.y
			target = get_global_mouse_position()
			
