extends Node
var is_init: bool = false
const API_BASE: String = "https://shibadb.xvcf.dev/api/v1"
var api_key: String = ""
var req
var logged_in = false
var active_callbacks = {}
signal api_response(res, code, headers, body)
signal save_loaded(saveData)

func sdb_log(message: String) -> void:
	print("[ShibaDB] " + str(message))

func _ready() -> void:
	req = HTTPRequest.new()
	req.request_completed.connect(self.handle_res)
	add_child(req)

func init_shibadb(key: String):
	if is_init:
		sdb_log("WARNING: ShibaDB should not be initialized more than once!")
		return
	api_key = key
	sdb_log("ShibaDB initialized!")
	is_init = true
	
func _handle_fetch_complete(args: Array) -> void:
	sdb_log("Handling fetch response...")
	var res = args[0]
	var code = args[1]
	var headers_str = args[2]
	var body_str = args[3]
	var headers = PackedStringArray()
	
	sdb_log("Res: " + str(res))
	sdb_log("Code: " + str(code))
	
	if headers_str:
		var header_lines = headers_str.split("\n")
		var filtered_headers = []
		for h in header_lines:
			if h.strip_edges() != "":
				filtered_headers.append(h)
		headers = PackedStringArray(filtered_headers)
				
	sdb_log("Headers: " + str(headers))
	
	var parse_result = JSON.parse_string(body_str)
	
	sdb_log("Body: " + str(parse_result))
	sdb_log("EMITTING API RESPONSE SIGNAL")
	api_response.emit(res, code, headers, parse_result)
	is_data_save(res, code, headers, parse_result)
	
func save_progress(values: Dictionary[String, Variant]) -> void:
	if OS.get_name() != "Web":
		sdb_log("Dynamically saving progress is not supported on this platform!")
		return
	var payload = "{\"saveData\": " + JSON.stringify(values) + "}"
	sdb_log(payload)
	var callable = Callable(self, "_handle_fetch_complete")
	var callback = JavaScriptBridge.create_callback(callable)
	var callback_name = "godot_shibadb_callback_save_" + str(Time.get_ticks_msec())
	active_callbacks[callback_name] = callback
	var window = JavaScriptBridge.get_interface("window")
	window[callback_name] = callback
	var js_payload = """
    fetch('%s', {
        method: 'POST',
        credentials: 'include',
        headers: {
            'Content-Type': 'application/json'
        },
        body: '%s'
    })
    .then(function(response) {
		var headers = "";
        response.headers.forEach(function(value, key) {
			headers += key + ":" + value + "\\n"
        });
        return [response.status, headers, response]
    })
    .then(function([status, headers_str, response]) {
        if (!response.ok) {
			throw new Error("HTTP " + status)
        }
        return response.text().then(function(text) {
            window.%s(0, status, headers_str, text)
        })
    })
    .catch(function(error) {
		window.%s(1, 0, "", "Error: " + error.message)
    })
	""" % [API_BASE + "/games/" + api_key + "/data", payload, callback_name, callback_name]
	JavaScriptBridge.eval(js_payload, true)

func reset_progress(save_name: String) -> void:
	if OS.get_name() != "Web":
		sdb_log("Dynamically resetting progress is not supported on this platform!")
		return
	var payload = "{\"saveName\": \"" + save_name + "\"}"
	sdb_log(payload)
	var callable = Callable(self, "_handle_fetch_complete")
	var callback = JavaScriptBridge.create_callback(callable)
	var callback_name = "godot_shibadb_callback_delete_" + str(Time.get_ticks_msec())
	active_callbacks[callback_name] = callback
	var window = JavaScriptBridge.get_interface("window")
	window[callback_name] = callback
	var js_payload = """
    fetch('%s', {
        method: 'DELETE',
        credentials: 'include',
        headers: {
            'Content-Type': 'application/json'
        },
        body: '%s'
    })
    .then(function(response) {
		var headers = "";
        response.headers.forEach(function(value, key) {
			headers += key + ":" + value + "\\n"
        });
        return [response.status, headers, response]
    })
    .then(function([status, headers_str, response]) {
        if (!response.ok) {
			throw new Error("HTTP " + status)
        }
        return response.text().then(function(text) {
            window.%s(0, status, headers_str, text)
        })
    })
    .catch(function(error) {
		window.%s(1, 0, "", "Error: " + error.message)
    })
	""" % [API_BASE + "/games/" + api_key + "/data", payload, callback_name, callback_name]
	JavaScriptBridge.eval(js_payload, true)

# WARNING: THIS SHOULD ONLY EVER BE USED IN DEVELOPMENT! DO NOT PUSH THIS TO PRODUCTION!!! THIS WILL LEAK YOUR SHIBADB TOKEN! USE DYNAMIC LOADING INSTEAD!
func save_progress_with_cookie(values: Dictionary[String, Variant], cookie: String) -> void:
	var payload = JSON.stringify(values, "\t")
	var err = req.request(API_BASE + "/games/" + api_key + "/data", ["Cookie: shibaCookie=" + cookie], HTTPClient.METHOD_POST, "{\"saveData\":" + payload + "}")
	if err != OK:
		sdb_log("Something went wrong while requesting ShibaDB!\n" + str(err))

func load_progress():
	if OS.get_name() != "Web":
		sdb_log("Dynamically loading progress is not supported on this platform!")
		return
	var callable = Callable(self, "_handle_fetch_complete")
	var callback = JavaScriptBridge.create_callback(callable)
	var callback_name = "godot_shibadb_callback_load_" + str(Time.get_ticks_msec())
	active_callbacks[callback_name] = callback
	var window = JavaScriptBridge.get_interface("window")
	window[callback_name] = callback
	var js_payload = """
    fetch('%s', {
        method: 'GET',
        credentials: 'include'
    })
    .then(function(response) {
		var headers = "";
        response.headers.forEach(function(value, key) {
			headers += key + ":" + value + "\\n"
        });
        return [response.status, headers, response]
    })
    .then(function([status, headers_str, response]) {
        if (!response.ok) {
			throw new Error("HTTP " + status)
        }
        return response.text().then(function(text) {
            window.%s(0, status, headers_str, text)
        })
    })
    .catch(function(error) {
		window.%s(1, 0, "", "Error: " + error.message)
    })
	""" % [API_BASE + "/games/" + api_key + "/data", callback_name, callback_name]
	JavaScriptBridge.eval(js_payload, true)

func handle_res(result, response_code, headers, body):
	var json = JSON.new()
	api_response.emit(result, response_code, headers, json.parse(body.get_string_from_utf8()))

func is_data_save(_res, code, _headers, body):
	sdb_log("is_data_save CALLED! Code: " + str(code) + ", Body type: " + str(typeof(body)))
	if code == 200:
		if body.has("success") && body.success && body.has("data"):
			if typeof(body.data) == TYPE_ARRAY && body.data.size() > 0:
				var save_object = body.data[0]
				if save_object.has("saveData"):
					sdb_log("VALID SAVE DATA!")
					sdb_log("Loaded save: " + str(save_object.saveData))
					save_loaded.emit(save_object.saveData)
				else:
					sdb_log("INVALID SAVE DATA! No saveData field in save object")
					sdb_log(str(body))
			else:
				sdb_log("NO SAVES FOUND! Data is empty or not an array")
				save_loaded.emit({})
		else:
			sdb_log("INVALID SAVE DATA! Missing success or data field")
			sdb_log(str(body))
	else:
		sdb_log("RES CODE " + str(code))
