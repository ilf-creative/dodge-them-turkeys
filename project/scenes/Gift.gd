extends RigidBody2D

func _ready():
	var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.animation = mob_types[randi() % mob_types.size()]
