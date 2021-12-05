extends CanvasLayer
signal start_game

var screen_size
var score_rect_start_height
var target_score_rect_height
var new_record = false

func _ready():
	$VersionLabel.text = "1.3.0"
	screen_size = get_viewport().get_visible_rect().size
	score_rect_start_height = $ScoreRect.rect_size.y
	_set_score_rect_fullscreen(true)

func _process(delta):
	if (!target_score_rect_height):
		return
	
	var scale = $ScoreRect.rect_size.y
	var speed = 10
	var limit_buffer = 50
	var step = speed * (-1 if scale > target_score_rect_height else 1)
	$ScoreRect.rect_size.y += step

	if abs($ScoreRect.rect_size.y - target_score_rect_height) < limit_buffer:
		$ScoreRect.rect_size.y = target_score_rect_height
		target_score_rect_height = null

func setGameState(state):
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
		$InfoButton.margin_top = 40
		$InfoButton.margin_bottom = 41
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
		$InfoButton.margin_top = 100
		$InfoButton.margin_bottom = 141
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
	yield($MessageTimer, "timeout")

	$MessageTimer.stop()
	$Message.text = text
	$Message.show()

	yield(get_tree().create_timer(1), "timeout")
	setGameState(HudGameState.END)

func update_score(score, time):
	var gift_s = "" if score == 1 else "s"
	$ScoreLabel.text = str(score) + " gift" + gift_s
	var timer_s = "" if time == 1 else "s"
	$TimerLabel.text = str(time) + " second" + timer_s

func show_high_scores(score, time, record = false):
	$RecordsLabel.text = "Most gifts saved: " + str(score) + "\nLongest time survived: " + str(time) + "s"
	new_record = record

func _on_MessageTimer_timeout():
	$Message.hide()

func _on_StartButton_pressed():
	emit_signal("start_game")

func _on_CodeButton_pressed():
	setGameState(HudGameState.INFO)

func _set_score_rect_fullscreen(fullscreen):
	target_score_rect_height = screen_size.y if fullscreen else score_rect_start_height


func _on_InfoScreen_exit():
	setGameState(HudGameState.START)
