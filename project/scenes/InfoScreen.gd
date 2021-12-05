extends CanvasLayer

signal exit

const HATS1_PID = "hatsonhats"
const HATS2_PID = "hatsonhatsonhats"

var bonus_hats

var in_app_store
var google_play_billing

func _ready():
	$Control/LoadingIndicator.hide()
	var settings = Settings.load_settings()
	bonus_hats = settings.bonus_hats
	_init_payment()
	_update_hat_display()

func purchase(pid):
	if in_app_store:
		in_app_store.set_auto_finish_transaction(true)
		var result = in_app_store.purchase({ "product_id": pid })
		if result == OK:
			_show_loader()
	elif google_play_billing:
		print("google_play_billing.purchase ... " + pid)
		_show_loader()
		var result = google_play_billing.purchase(pid)
		print("gpb result... " + str(result))

func _show_loader(msg=" LOADING "):
	$Control/LoadingIndicator/LoaderLabel.text = msg
	$Control/LoadingIndicator.show()

func check_events():
	if !in_app_store:
		return

	while in_app_store.get_pending_event_count() > 0:
		var event = in_app_store.pop_pending_event()
		if event.type == "purchase" or event.type == "restore":
			if event.result == "progress":
				pass
			elif event.result == "ok":
				_on_purchase_success(event.product_id)
				$Control/LoadingIndicator.hide()
			elif event.type == "purchase":
				OS.alert("An error occured trying to process your purchase")

func _on_purchase_success(pid):
	if pid == HATS1_PID and bonus_hats < 1:
		_set_hats(1)
	elif pid == HATS2_PID and bonus_hats < 2:
		_set_hats(2)

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

func _set_hats(new_value):
	bonus_hats = new_value
	var settings = Settings.load_settings()
	settings.bonus_hats = new_value
	settings.save_file()
	_update_hat_display()
	
func _on_Buy1_pressed():
	if bonus_hats > 0:
		return
	
	purchase(HATS1_PID)

func _on_Buy2_pressed():
	if bonus_hats > 1:
		return
	
	if bonus_hats < 1:
		OS.alert("You cannot buy 'hats on hats on hats' until you buy 'hats on hats'... duh.")
		return
	
	purchase(HATS2_PID)

func _on_InAppPurchaseCheckTimer_timeout():
	check_events()

func _on_connected():
	print("_on_connected_on_connected")
	google_play_billing.querySkuDetails([HATS1_PID, HATS2_PID], "inapp")

	var query = google_play_billing.queryPurchases("inapp")
	if query.status == OK:
		_on_purchases_updated(query.purchases)

func _on_purchases_updated(purchases):
	print("_on_purchases_updated_on_purchases_updated_on_purchases_updated")
	for purchase in purchases:
		if purchase.purchase_state == 1: # 1 means "purchased", see https://developer.android.com/reference/com/android/billingclient/api/Purchase.PurchaseState#constants_1
			_on_purchase_success(purchase.sku)
			$Control/LoadingIndicator.hide()
			if not purchase.is_acknowledged:
				google_play_billing.acknowledgePurchase(purchase.purchase_token)

func _on_connect_error(id, msg):
	print("connect errror" + " -- " + str(id) + " -- " + str(msg))
	
func _on_purchase_error(id, msg):
	print("_on_purchase_error" + " -- " + str(id) + " -- " + str(msg))

func _on_sku_details_query_completed(skus):
	print("_on_sku_details_query_completed " + str(skus))
	if skus.size() < 2:
		_show_loader(" CURRENTLY UNAVAILABLE ")

	for z in skus:
		print(z)

func _init_payment():
	var can_pay = false
	if Engine.has_singleton("InAppStore"):
		in_app_store = Engine.get_singleton("InAppStore")
		var result = in_app_store.request_product_info({ "product_ids": [HATS1_PID, HATS2_PID] })
		$InAppPurchaseCheckTimer.start()
		in_app_store.restore_purchases()
		can_pay = true
	else:
		print("iOS IAP plugin is not available on this platform.")
	
	if Engine.has_singleton("GodotGooglePlayBilling"):
		google_play_billing = Engine.get_singleton("GodotGooglePlayBilling")
		google_play_billing.connect("connected", self, "_on_connected") # No params
		# google_play_billing.connect("disconnected", self, "_on_disconnected") # No params
		google_play_billing.connect("connect_error", self, "_on_connect_error") # Response ID (int), Debug message (string)
		google_play_billing.connect("purchases_updated", self, "_on_purchases_updated") # Purchases (Dictionary[])
		google_play_billing.connect("purchase_error", self, "_on_purchase_error") # Response ID (int), Debug message (string)
		google_play_billing.connect("sku_details_query_completed", self, "_on_sku_details_query_completed") # SKUs (Dictionary[])
		# google_play_billing.connect("sku_details_query_error", self, "_on_sku_details_query_error") # Response ID (int), Debug message (string), Queried SKUs (string[])
		# google_play_billing.connect("purchase_acknowledged", self, "_on_purchase_acknowledged") # Purchase token (string)
		# google_play_billing.connect("purchase_acknowledgement_error", self, "_on_purchase_acknowledgement_error") # Response ID (int), Debug message (string), Purchase token (string)
		# google_play_billing.connect("purchase_consumed", self, "_on_purchase_consumed") # Purchase token (string)
		# google_play_billing.connect("purchase_consumption_error", self, "_on_purchase_consumption_error") # Response ID (int), Debug message (string), Purchase token (string)
		google_play_billing.startConnection()
		can_pay = true
	else:
		print("Android IAP support is not enabled.")
		
	if !can_pay:
		_show_loader(" CURRENTLY UNAVAILABLE ")
