extends CanvasLayer
signal start_game

var screen_size
var score_rect_start_height
var target_score_rect_height

func _ready():
	$VersionLabel.text = "1.1.4"
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
	$StartButton.hide()
	$InfoButton.hide()
	$ScoreLabel.hide()
	$TimerLabel.hide()
	$VersionLabel.hide()
	$Logo.hide()
	$RecordsLabel.hide()
	
	if state == HudGameState.START:
		$StartButton.show()
		$VersionLabel.show()
		$Logo.show()
		$StartButton.text = " START "
	elif state == HudGameState.PLAYING:
		print("hide it!!")
		$ScoreLabel.show()
		$TimerLabel.show()
		_set_score_rect_fullscreen(false)
	elif state == HudGameState.END:
		$StartButton.show()
		$InfoButton.show()
		$ScoreLabel.show()
		$TimerLabel.show()
		$VersionLabel.show()
		$RecordsLabel.show()
		$StartButton.text = " TRY AGAIN "
		_set_score_rect_fullscreen(true)
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

func show_high_scores(score, time):
	$RecordsLabel.text = "Most gifts saved: " + str(score) + "\nLongest time survived: " + str(time) + "s"

func _on_MessageTimer_timeout():
	$Message.hide()


func _on_StartButton_pressed():
	emit_signal("start_game")

func _on_CodeButton_pressed():
	OS.shell_open("https://github.com/ilf-creative/dodge-them-turkeys")

func _set_score_rect_fullscreen(fullscreen):
	target_score_rect_height = screen_size.y if fullscreen else score_rect_start_height
