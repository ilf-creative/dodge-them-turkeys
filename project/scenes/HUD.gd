extends CanvasLayer
signal start_game

var screen_size
var score_rect_start_height
var target_score_rect_height
var new_record = false

func _ready():
	$VersionLabel.text = "1.3.3"
	screen_size = get_viewport().get_visible_rect().size
	score_rect_start_height = $ScoreRect.size.y
	_set_score_rect_fullscreen(true)

func _process(_delta):
	if (!target_score_rect_height):
		return
	
	var scaleY = $ScoreRect.size.y
	var speed = 10
	var limit_buffer = 50
	var step = speed * (-1 if scaleY > target_score_rect_height else 1)
	$ScoreRect.size.y += step

	if abs($ScoreRect.size.y - target_score_rect_height) < limit_buffer:
		$ScoreRect.size.y = target_score_rect_height
		target_score_rect_height = null

func set_game_state(state):
	$InfoScreen.get_child(0).hide()
	$StartButton.hide()
	$InfoButton.hide()
	$ScoreLabel.hide()
	$TimerLabel.hide()
	$VersionLabel.hide()
	$Logo.hide()
	$RecordsLabel.hide()
	$BlackTitleRect.hide()
	$NewRecord.hide()
	
	if state == HudGameState.START:
		$StartButton.show()
		$VersionLabel.show()
		$InfoButton.show()
		$InfoButton.offset_top = 40
		$InfoButton.offset_bottom = 41
		$Logo.show()
		$Message.hide()
		$StartButton.text = " START "
	elif state == HudGameState.PLAYING:
		$ScoreLabel.show()
		$TimerLabel.show()
		$BlackTitleRect.show()
		_set_score_rect_fullscreen(false)
	elif state == HudGameState.END:
		$StartButton.show()
		$InfoButton.show()
		$ScoreLabel.show()
		$InfoButton.offset_top = 100
		$InfoButton.offset_bottom = 141
		$TimerLabel.show()
		$VersionLabel.show()
		$RecordsLabel.show()
		$BlackTitleRect.show()
		if new_record:
			$NewRecord.show()
		$StartButton.text = " TRY AGAIN "
		_set_score_rect_fullscreen(true)
	elif state == HudGameState.INFO:
		$InfoScreen.get_child(0).show()
		$Message.hide()
	elif state == HudGameState.SPLASH:
		$Logo.show()

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over(text):
	show_message("GAME OVER")
	await $MessageTimer.timeout

	$MessageTimer.stop()
	$Message.text = text
	$Message.show()

	await get_tree().create_timer(1).timeout
	set_game_state(HudGameState.END)

func update_score(score, time):
	$ScoreLabel.text = Utils.s_plural("gift", score)
	$TimerLabel.text = Utils.s_plural("second", time)

func show_high_scores(score, time, record = false):
	$RecordsLabel.text = "Most gifts saved: " + str(score) + "\nLongest time survived: " + str(time) + "s"
	new_record = record

func _set_score_rect_fullscreen(fullscreen):
	target_score_rect_height = screen_size.y if fullscreen else score_rect_start_height

########### event listeners ###############################################

func _on_MessageTimer_timeout():
	$Message.hide()

func _on_StartButton_pressed():
	emit_signal("start_game")

func _on_CodeButton_pressed():
	set_game_state(HudGameState.INFO)

func _on_InfoScreen_exit():
	set_game_state(HudGameState.START)
