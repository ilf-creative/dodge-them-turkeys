extends CanvasLayer
signal start_game

func show():
	$Message.show()
	$StartButton.show()
	$ScoreLabel.show()
	
func hide():
	$Message.hide()
	$StartButton.hide()
	$ScoreLabel.hide()

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over(text):
	show_message("GAME OVER")
	# Wait until the MessageTimer has counted down.
	yield($MessageTimer, "timeout")

	$MessageTimer.stop()
	$Message.text = text
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	yield(get_tree().create_timer(1), "timeout")
	$StartButton.show()

func update_score(score):
	var gift_s = "" if score == 1 else "s"
	$ScoreLabel.text = str(score) + " gift" + gift_s


func _on_MessageTimer_timeout():
	$Message.hide()


func _on_StartButton_pressed():
	$StartButton.hide()
	emit_signal("start_game")
