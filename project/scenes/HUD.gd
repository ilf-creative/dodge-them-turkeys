extends CanvasLayer
signal start_game

func _ready():
	$VersionLabel.text = "1.1.2"

func show():
	$Message.show()
	$StartButton.show()
	$CodeButton.show()
	$ScoreLabel.show()
	
func hide():
	$Message.hide()
	$StartButton.hide()
	$CodeButton.hide()
	$ScoreLabel.hide()

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
	$StartButton.show()
	$CodeButton.show()
	$VersionLabel.show()

func update_score(score):
	var gift_s = "" if score == 1 else "s"
	$ScoreLabel.text = str(score) + " gift" + gift_s


func _on_MessageTimer_timeout():
	$Message.hide()


func _on_StartButton_pressed():
	$StartButton.hide()
	$CodeButton.hide()
	$VersionLabel.hide()
	emit_signal("start_game")


func _on_CodeButton_pressed():
	OS.shell_open("https://github.com/ilf-creative/dodge-them-turkeys")
