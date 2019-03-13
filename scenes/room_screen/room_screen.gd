extends Control


var MenuScreen = load("res://scenes/menu_screen/menu_screen.tscn")
var GameScreen = load("res://scenes/game_screen/game_screen.tscn")

var info

func _ready():
	info = shared.data
	var _err = driver.connect("event_received", self, "_on_network_event")	
	
	
	$Panel/RightArea/Title.text = info.title
	$Panel/RightArea/Description.text = info.description
	
	$Panel/Numpad.numbers = info.id
	
	var is_owner = credentials_store.username == info.owner
	$Panel/RightArea/Players.init(info.players, info.capacity, is_owner)
	$Panel/ButtonStartGame.visible = is_owner
	_update_start_button_status()


func _on_network_event(name, data):
	match name:
		"joined":
			$Panel/RightArea/Players.player_joined(data)
			_update_start_button_status()
		
		"left":
			if data == credentials_store.username:
				var _err = get_tree().change_scene_to(MenuScreen)
			else:
				$Panel/RightArea/Players.player_left(data)
				_update_start_button_status()
			
		"kicked":
			if data == credentials_store.username:
				$StatusPanel.visible = true
				$StatusPanel/Panel/Label.text = "you have been kicked out of the room"
				
				yield(get_tree().create_timer(2), "timeout")
				var _err = get_tree().change_scene_to(MenuScreen)
			else:
				$Panel/RightArea/Players.player_left(data)
				_update_start_button_status()
		
		"dismissed":
			$StatusPanel.visible = true
			$StatusPanel/Panel/Label.text = "the room is closing"
				
			yield(get_tree().create_timer(2), "timeout")
			var _err = get_tree().change_scene_to(MenuScreen)
			
		"game_started":
			shared.data = data
			shared.data.players = $Panel/RightArea/Players.player_list
			var _err = get_tree().change_scene_to(GameScreen)

		_:
			print("Unhandled event: %s %s" % [name, data])

func _update_start_button_status():
	$Panel/ButtonStartGame.disabled = not $Panel/RightArea/Players.is_full()

func _on_button_leave_pressed():
	driver.remote_cast("leave", null)


func _on_kick_player(name):
	driver.remote_cast("kick", [name])


func _on_start_game_button_pressed():
	driver.remote_cast("start_game", [])
