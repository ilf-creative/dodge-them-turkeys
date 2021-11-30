extends Node

export (PackedScene) var Mob
export (PackedScene) var Gift
var score = 0 
var screen_size: Vector2
var mob_spawn_count = 1.0
var seconds_survived = 0

func _ready():
	randomize()
	_initViewport()
	_playIntro()
	
func _game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$GiftTimer.stop()
	var second_survived_s = "" if seconds_survived == 1 else "s"
	$HUD.show_game_over("You survived " + str(seconds_survived) + " second" + second_survived_s + ".")
	$BackgroundMusic.stop()
	$DeathAudio.play()
	_reset_game_state()
	
	mob_spawn_count = 1
	for n in 50:
		_on_MobTimer_timeout()
		yield(get_tree().create_timer(0.001), "timeout")

func _new_game():
	_reset_game_state()
		
	$Player.start($StartPosition.position)
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$BackgroundMusic.play()
	_on_GiftTimer_timeout()
	$StartTimer.start()

func _reset_game_state():
	score = 0
	seconds_survived = 0
	mob_spawn_count = 2 if screen_size.x > 800 else 1
	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("gifts", "queue_free")

func _initViewport():
	screen_size = get_viewport().get_visible_rect().size
	
	var viewport_w = screen_size.x
	var viewport_h = screen_size.y
	
	var mob_buffer = 50
	$MobPath.curve.clear_points()
	$MobPath.curve.add_point(Vector2(-mob_buffer, -mob_buffer))
	$MobPath.curve.add_point(Vector2(viewport_w + mob_buffer, -mob_buffer))
	$MobPath.curve.add_point(Vector2(viewport_w + mob_buffer,viewport_h + mob_buffer))
	$MobPath.curve.add_point(Vector2(-mob_buffer, viewport_h + mob_buffer))
	$MobPath.curve.add_point(Vector2(-mob_buffer, -mob_buffer))
	
	var background_size = $Background.texture.get_size()
	var scale_x = viewport_w / background_size.x
	var scale_y = viewport_h / background_size.y

	$Background.set_scale(Vector2(scale_x, scale_y))
	$Background.hide()
	
	var turkey_background_size = $TurkeySanta.texture.get_size()
	var turkey_scale_x = min(500, viewport_w) / turkey_background_size.x
	var turkey_scale_y = viewport_h / turkey_background_size.y
	$TurkeySanta.set_scale(Vector2(turkey_scale_x, turkey_scale_y))
	$TurkeySanta.rect_position.x = (viewport_w - (800 * turkey_scale_x)) / 2
	$TurkeySanta.show()
	$HUD.hide()

func _playIntro():
	var turkey_background_size = $TurkeySanta.texture.get_size()
	var turkey_scale_y = screen_size.y / turkey_background_size.y
	var turkey_offset = turkey_background_size.y
	var turkey_stop = turkey_scale_y * 400

	while(turkey_offset > turkey_stop):
		yield(get_tree().create_timer(0.001), "timeout")
		$TurkeySanta.rect_position.y = turkey_offset + 100
		turkey_offset -= 20

	yield(get_tree().create_timer(3), "timeout")
	
	$Background.show()
	$Background.set_modulate(Color(1,1,1,0))
	
	for n in 30:
		$Background.set_modulate(lerp($Background.get_modulate(), Color(1,1,1,1), 0.2))
		yield(get_tree().create_timer(0.001), "timeout")

	$TurkeySanta.hide()
	$HUD.show()	

########### event listeners ###############################################

func _on_Player_hit():
	_game_over()

func _on_MobTimer_timeout():
	mob_spawn_count += 0.1
	for n in floor(mob_spawn_count):
		$MobPath/MobSpawnLocation.offset = randi()
		var mob = Mob.instance()
		add_child(mob)
		var direction = $MobPath/MobSpawnLocation.rotation + PI / 2
		mob.position = $MobPath/MobSpawnLocation.position
		direction += rand_range(-PI / 4, PI / 4)
		mob.rotation = direction
		mob.linear_velocity = Vector2(rand_range(mob.min_speed, mob.max_speed), 0)
		mob.linear_velocity = mob.linear_velocity.rotated(direction)

func _on_ScoreTimer_timeout():
	seconds_survived += 1

func _on_StartTimer_timeout():
	$MobTimer.start()
	$GiftTimer.start()
	$ScoreTimer.start()

func _on_HUD_start_game():
	_new_game()

func _on_GiftTimer_timeout():
	var gift = Gift.instance()
	add_child(gift)
	gift.position = Vector2(rand_range(0, screen_size.x), rand_range(0, screen_size.y))
	
func _on_Player_gifted():
	score += 1
	$HUD.update_score(score)
	$GiftAudio.stop()
	$GiftAudio.play()
	
