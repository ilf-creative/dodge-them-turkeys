extends CanvasLayer

signal exit

var bonus_hats

func _ready():
	var settings = Settings.load_settings()
	# settings.bonus_hats = 0
	# settings.save_file()
	bonus_hats = settings.bonus_hats
	_update_hat_display()

func _on_Exit_pressed():
	emit_signal("exit")

func _on_InfoButton2_pressed():
	OS.shell_open("https://github.com/ilf-creative/dodge-them-turkeys")

func _update_hat_display():
	
	if bonus_hats < 1:
		$Control/Buy1/Check.hide()
	else:
		$Control/Buy1/Check.show()
	if bonus_hats < 2:
		$Control/Buy2/Check.hide()
	else:
		$Control/Buy2/Check.show()

func _on_Buy1_pressed():
	if bonus_hats > 0:
		return
		
	bonus_hats = 1
	var settings = Settings.load_settings()
	settings.bonus_hats = bonus_hats
	settings.save_file()
	_update_hat_display()


func _on_Buy2_pressed():
	if bonus_hats > 1:
		return
	
	if bonus_hats < 1:
		OS.alert("You cannot buy hats on hats on hats until you buy hats on hats.")
		return
	
	bonus_hats = 2
	var settings = Settings.load_settings()
	settings.bonus_hats = bonus_hats
	settings.save_file()
	_update_hat_display()
