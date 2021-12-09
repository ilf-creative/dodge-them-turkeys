class_name PaymentGoogle

var can_pay = false
var product_list = []

var _on_error
var _on_success
var _google_play_billing


func _init(products: Array, pay_success: FuncRef, pay_error: FuncRef):
	product_list = products
	_on_error = pay_error
	_on_success = pay_success
	
	if Engine.has_singleton("GodotGooglePlayBilling"):
		_google_play_billing = Engine.get_singleton("GodotGooglePlayBilling")
		_google_play_billing.connect("connected", self, "_on_connected") # No params
		_google_play_billing.connect("connect_error", self, "_on_connect_error") # Response ID (int), Debug message (string)
		_google_play_billing.connect("purchases_updated", self, "_on_purchases_updated") # Purchases (Dictionary[])
		_google_play_billing.connect("purchase_error", self, "_on_purchase_error") # Response ID (int), Debug message (string)
		_google_play_billing.connect("sku_details_query_completed", self, "_on_sku_details_query_completed") # SKUs (Dictionary[])
		
		# not needed .. maybe one day?
		# _google_play_billing.connect("disconnected", self, "_on_disconnected") # No params
		# _google_play_billing.connect("sku_details_query_error", self, "_on_sku_details_query_error") # Response ID (int), Debug message (string), Queried SKUs (string[])
		# _google_play_billing.connect("purchase_acknowledged", self, "_on_purchase_acknowledged") # Purchase token (string)
		# _google_play_billing.connect("purchase_acknowledgement_error", self, "_on_purchase_acknowledgement_error") # Response ID (int), Debug message (string), Purchase token (string)
		# _google_play_billing.connect("purchase_consumed", self, "_on_purchase_consumed") # Purchase token (string)
		# _google_play_billing.connect("purchase_consumption_error", self, "_on_purchase_consumption_error") # Response ID (int), Debug message (string), Purchase token (string)
		
		_google_play_billing.startConnection()
		can_pay = true
	else:
		print("Android IAP support is not enabled.")
		can_pay = false
		
func purchase(pid: String):
	if !_google_play_billing:
		_on_purchase_error(-999, "purchase not initialized")
		return false

	var result = _google_play_billing.purchase(pid)

	if !result or !result.has('status'):
		return false
	else: 
		return result['status'] == 0 # 0 == success ... https://github.com/godotengine/godot-google-play-billing/blob/079b11192f2541d0925116db658145d06ea3a265/godot-google-play-billing/src/main/java/org/godotengine/godot/plugin/googleplaybilling/GodotGooglePlayBilling.java#L250

func _on_connected():
	_google_play_billing.querySkuDetails(product_list, "inapp")

	var query = _google_play_billing.queryPurchases("inapp")
	if query.status == OK:
		_on_purchases_updated(query.purchases)

func _on_purchases_updated(purchases: Array):
	for purchase in purchases:
		if purchase.purchase_state == 1: # 1 means "purchased", see https://developer.android.com/reference/com/android/billingclient/api/Purchase.PurchaseState#constants_1
			_on_success.call_funcv([purchase.sku])
			if not purchase.is_acknowledged:
				_google_play_billing.acknowledgePurchase(purchase.purchase_token)

func _on_connect_error(id: int, msg: String):
	_on_purchase_error(-999, "Unable to connect")
	
func _on_purchase_error(id: int, msg: String):
	_on_error.call_funcv([id, msg])

func _on_sku_details_query_completed(skus: Array):
	if skus.size() < 2:
		_on_error.call_funcv([-999])
