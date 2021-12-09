class_name PaymentApple

var can_pay = false
var product_list = []

var _on_error
var _on_success
var _in_app_store

func _init(products: Array, pay_success: FuncRef, pay_error: FuncRef):
	product_list = products
	_on_error = pay_error
	_on_success = pay_success
	
	if Engine.has_singleton("InAppStore"):
		_in_app_store = Engine.get_singleton("InAppStore")
		_in_app_store.request_product_info({ "product_ids": products })
		_in_app_store.restore_purchases()
		can_pay = true
	else:
		can_pay = false
		print("iOS IAP plugin is not available on this platform.")

func purchase(pid: String):
	_in_app_store.set_auto_finish_transaction(true)
	var result = _in_app_store.purchase({ "product_id": pid })
	return result == OK

func check_state():
	if !_in_app_store:
		return

	while _in_app_store.get_pending_event_count() > 0:
		var event = _in_app_store.pop_pending_event()
		if event.type == "purchase" or event.type == "restore":
			if event.result == "progress":
				pass
			elif event.result == "ok":
				_on_success.call_funcv([event.product_id])
			elif event.type == "purchase":
				_on_error.call_funcv([1, "error"])
