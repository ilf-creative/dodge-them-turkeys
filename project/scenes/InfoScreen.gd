extends CanvasLayer

signal exit

const HATS1_PID = "hatsonhats"
const HATS2_PID = "hatsonhatsonhats"

var bonus_hats

var payment

func _ready():
	$Control/LoadingIndicator.hide()
	var settings = Settings.load_settings()
	bonus_hats = settings.bonus_hats
	_init_payment()
	_update_hat_display()

func purchase(pid):
	if !payment.can_pay:
		OS.alert("Unable to purchase at this time.")
		return

	_show_loader()
	var result = payment.purchase(pid)
	if !result:
		$Control/LoadingIndicator.hide()
		OS.alert("Unable to make a purchase at this time")

func _show_loader(msg=" LOADING "):
	$Control/LoadingIndicator/LoaderLabel.text = msg
	$Control/LoadingIndicator.show()

func _update_hat_display():
	if bonus_hats < 1:
		$Control/Buy1/Check.hide()
	else:
		$Control/Buy1/Check.show()
	if bonus_hats < 2:
		$Control/Buy2/Check.hide()
	else:
		$Control/Buy2/Check.show()

func _set_hats(new_value):
	bonus_hats = new_value
	var settings = Settings.load_settings()
	settings.bonus_hats = new_value
	settings.save_file()
	_update_hat_display()
	
func _init_payment():
	var on_success = funcref(self, "_on_payment_success")
	var on_error = funcref(self, "_on_payment_error")
	payment = Payment.new([HATS1_PID, HATS2_PID], on_success, on_error)

	if payment.can_pay:
		$InAppPurchaseCheckTimer.start()
	else:
		_show_loader(" CURRENTLY UNAVAILABLE ")

########### event listeners ###############################################

func _on_payment_success(pid):
	$Control/LoadingIndicator.hide()
	if pid == HATS1_PID and bonus_hats < 1:
		_set_hats(1)
	elif pid == HATS2_PID and bonus_hats < 2:
		_set_hats(2)

func _on_payment_error(id, msg):
	$Control/LoadingIndicator.hide()
	OS.alert("There was an error processing your payment")
	
	if (id == -999):
		_show_loader(" CURRENTLY UNAVAILABLE ")
		return

func _on_InAppPurchaseCheckTimer_timeout():
	payment.check_state()

func _on_Exit_pressed():
	emit_signal("exit")

func _on_InfoButton2_pressed():
	OS.shell_open("https://github.com/ilf-creative/dodge-them-turkeys")

func _on_Buy1_pressed():
	if bonus_hats > 0:
		OS.alert("You already purchased hats on hats... thank you")
		return
	
	purchase(HATS1_PID)

func _on_Buy2_pressed():
	if bonus_hats > 1:
		OS.alert("You already purchased hats on hats on hats... thank you")
		return
	
	if bonus_hats < 1:
		OS.alert("You cannot buy 'hats on hats on hats' until you buy 'hats on hats'... duh.")
		return
	
	purchase(HATS2_PID)
