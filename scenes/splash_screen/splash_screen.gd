extends Control


var MenuScreen = preload("res://scenes/menu_screen/menu_screen.tscn")
var url = "ws://fyp.3warriors.tk:5657"
# var url = "ws://127.0.0.1:5657"

var t

func _ready():
	print(OS.get_user_data_dir()) # For debugging purpose only
	
	# Wait a samll amount of time before connect to the server
	yield(get_tree().create_timer(1), "timeout")
	
	t = OS.get_ticks_msec()
	$Status.text = "connecting to server at %s" % [url]
	driver.connect_to_url(url)
	driver.connect("connection_established", self, "_on_connection_established")
	driver.connect("connection_error", self, "_on_connection_error")

func _proceed_login():
	$Status.text = "logging you in, please wait"

	$LoginPanel/Panel/Message.text = "logging in as %s" % [credentials_store.username]
	$LoginPanel.visible = true
	
	var call = driver.remote_call("login", [credentials_store.username, credentials_store.password])
	var result = yield(call, "result")
	
	if result.status == "ok":
		get_tree().change_scene_to(MenuScreen)
	else:
		$LoginPanel.visible = false
		_proceed_registration()

func _proceed_registration():
	$Status.text = "please create an account first"
	$RegisterPanel.visible = true

func _on_connection_established():
	yield(get_tree().create_timer(_atleast(t, 1)), "timeout")
	$Status.text = "connected to server (%s)" % [url]

	if credentials_store.username == null:
		_proceed_registration()
	else:
		_proceed_login()

func _on_connection_error(reason):
	$Status.text = "server disconnected %s" % [reason]


func _on_Button_pressed():
	var username = $RegisterPanel/Panel/Username.text
	var password = str(randi()) + str(randi()) + str(randi())
	print("username = %s, password = %s" % [username, password])
	
	var call = driver.remote_call("register", [username, password])
	var result = yield(call, "result")
	
	if result.status == "ok":
		credentials_store.username = username
		credentials_store.password = password
		credentials_store.save_data()
		$RegisterPanel.visible = false
		
		_proceed_login()
	else:
		$RegisterPanel/Panel/StatusBar.text = result.reason

func _atleast(timestamp, duration_sec):
	var duration = duration_sec * 1000
	var elasped = OS.get_ticks_msec() - timestamp
	return max((duration - elasped) / 1000, 0)