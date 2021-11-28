extends Area2D
signal hit
signal gifted

export var speed = 400
var screen_size
var target = Vector2.ZERO
var oldTarget = Vector2.ZERO

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	target = Vector2.ZERO

func _ready():
	screen_size = get_viewport_rect().size
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	var velocity = Vector2()  # The player's movement vector.
	
	if (target != Vector2.ZERO): # touch control
		var distance = (target - position)
		if (distance.length() > 5):
			velocity = (target - position).normalized()
			$AnimatedSprite.play()
		else:
			$AnimatedSprite.stop()
			velocity = Vector2.ZERO
			
	else: # keyboard control
		if Input.is_action_pressed("ui_right"):
			velocity.x += 1
		if Input.is_action_pressed("ui_left"):
			velocity.x -= 1
		if Input.is_action_pressed("ui_down"):
			velocity.y += 1
		if Input.is_action_pressed("ui_up"):
			velocity.y -= 1
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
		
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	var angle = abs(rad2deg(velocity.angle()))
	var isUpDownAngle = angle > 60 and angle < 120

	if velocity.x != 0 and !isUpDownAngle:
		$AnimatedSprite.animation = "walk"
		$AnimatedSprite.flip_v = false
		# See the note below about boolean assignment
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.y != 0 or isUpDownAngle:
		$AnimatedSprite.animation = "down" if velocity.y > 0 else "up"
		# $AnimatedSprite.flip_v = velocity.y > 0

func _on_Player_body_entered(body):
	if body.is_in_group("mobs"):
		hide()  # Player disappears after being hit.
		emit_signal("hit")
		$CollisionShape2D.set_deferred("disabled", true)
	elif body.is_in_group("gifts"):
		emit_signal("gifted")
		body.queue_free()
	

func _input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.is_pressed():
			var x = event.position.x
			var y = event.position.y
			target = get_global_mouse_position()
			
