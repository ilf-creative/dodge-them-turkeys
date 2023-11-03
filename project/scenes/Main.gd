extends Node

@export var Mob:PackedScene
@export var Gift:PackedScene

const GIFT_SCREEN_BUFFER_TOP = 100
const GIFT_SCREEN_BUFFER = 40
const BACKGROUND_RESET_TIMEOUT = 30

var score = 0
var screen_size: Vector2
var mob_spawn_count = 1.0
var seconds_survived = 0
var starting_hats = 1
var game_running = false
var background_time = 0

func _ready():
	randomize()
	_init_viewport()
	_play_intro()
	
func _game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$GiftTimer.stop()
	$HUD.show_game_over("You survived " + Utils.s_plural("second", seconds_survived) + ", and saved " + Utils.s_plural("gift", score) + ".")
	$BackgroundMusic.stop()
	$DeathAudio.play()
	_update_high_scores()
	_reset_game_state()
	# deferred to avoid error: godot Can't change this state while flushing queries
	call_deferred("_show_end_turkeys")
	
func _show_end_turkeys():
	for n in 50:
		_on_MobTimer_timeout()
		await get_tree().create_timer(0.001).timeout
	
func _update_high_scores():
	var settings = Settings.load_settings()
	var new_record = true if score > settings.most_gifts || seconds_survived > settings.longest_survival else false
	settings.most_gifts = max(settings.most_gifts, score)
	settings.longest_survival = max(settings.longest_survival, seconds_survived)
	settings.save_file()
	$HUD.show_high_scores(settings.most_gifts, settings.longest_survival, new_record)

func _new_game():
	_reset_game_state()
	$Player.start($StartPosition.position, starting_hats)
	$HUD.update_score(score, seconds_survived)
	$HUD.show_message("Get Ready")
	$BackgroundMusic.play()
	$HUD.set_game_state(HudGameState.PLAYING)
	$StartTimer.start()
	game_running = true

func _reset_game_state():
	game_running = false
	score = 0
	seconds_survived = 0
	mob_spawn_count = 2 if screen_size.x > 800 else 1
	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("gifts", "queue_free")
	var settings = Settings.load_settings()
	starting_hats = settings.bonus_hats + 1

func _init_viewport():
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
	$HUD.set_game_state(HudGameState.SPLASH)

func _play_intro():
	await get_tree().create_timer(2).timeout
	
	$Background.show()
	$Background.set_modulate(Color(1,1,1,0))
	
	for n in 30:
		$Background.set_modulate(lerp($Background.get_modulate(), Color(1,1,1,1), 0.2))
		await get_tree().create_timer(0.001).timeout

	$HUD.set_game_state(HudGameState.START)

########### event listeners ###############################################

func _on_Player_hit():
	_game_over()

func _on_MobTimer_timeout():
	var turkey_hats = starting_hats - $Player.hats
	var showing_hats = 0
	
	if turkey_hats > 0:
		var other_turkeys = get_tree().get_nodes_in_group("mobs")
		for t in other_turkeys:
			if t.has_hat:
				showing_hats += 1
	
	mob_spawn_count += 0.1
	for n in floor(mob_spawn_count):
		$MobPath/MobSpawnLocation.progress = randi()
		var mob = Mob.instantiate()
		add_child(mob)
		var direction = $MobPath/MobSpawnLocation.rotation + PI / 2
		mob.position = $MobPath/MobSpawnLocation.position
		direction += randf_range(-PI / 4, PI / 4)
		mob.rotation = direction
		mob.linear_velocity = Vector2(randf_range(mob.min_speed, mob.max_speed), 0)
		mob.linear_velocity = mob.linear_velocity.rotated(direction)
		if showing_hats < turkey_hats:
			mob.has_hat = true
			showing_hats+=1

func _on_ScoreTimer_timeout():
	seconds_survived += 1
	$HUD.update_score(score, seconds_survived)

func _on_StartTimer_timeout():
	$MobTimer.start()
	$GiftTimer.start()
	$ScoreTimer.start()
	_on_GiftTimer_timeout()

func _on_HUD_start_game():
	_new_game()

func _on_GiftTimer_timeout():
	var other_gifts = get_tree().get_nodes_in_group("gifts")
	
	# try 10 times to find a spot to put a gift that is not too close to another gift or the player
	var gift_pos: Vector2
	var found_too_close = false
	for i in 10:
		gift_pos = Vector2(randf_range(GIFT_SCREEN_BUFFER, screen_size.x - GIFT_SCREEN_BUFFER), randf_range(GIFT_SCREEN_BUFFER_TOP, screen_size.y - GIFT_SCREEN_BUFFER))
		found_too_close = false
		if gift_pos.distance_to($Player.position) < 100:
			found_too_close = true
			continue

		for g in other_gifts:
			if gift_pos.distance_to(g.position) < 100:
				found_too_close = true
				break

		if !found_too_close:
			break
	
	if found_too_close:
		return
	
	var gift = Gift.instantiate()
	add_child(gift)
	gift.position = gift_pos
	
func _on_Player_gifted():
	score += 1
	$HUD.update_score(score, seconds_survived)
	$GiftAudio.stop()
	$GiftAudio.play()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
			background_time = Time.get_unix_time_from_system()
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
			var now = Time.get_unix_time_from_system()
			if !game_running and now - background_time > BACKGROUND_RESET_TIMEOUT:
				$HUD.set_game_state(HudGameState.START)
