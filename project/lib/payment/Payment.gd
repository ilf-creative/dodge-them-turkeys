class_name Payment

var apple
var google
var can_pay = false

func _init(products, pay_success: FuncRef, pay_error: FuncRef):
	apple = PaymentApple.new(products, pay_success, pay_error)
	google = PaymentGoogle.new(products, pay_success, pay_error)
	can_pay = apple.can_pay or google.can_pay

# must be called in a timer for Apple Pay... not needed for google
func check_state():
	if apple.can_pay:
		apple.check_state()

func purchase(pid):
	if apple.can_pay:
		return apple.purchase(pid)

	if google.can_pay:
		return google.purchase(pid)
