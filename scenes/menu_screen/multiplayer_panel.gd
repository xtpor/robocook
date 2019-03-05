extends Control

signal join_room(numbers)

var RoomScreen = preload("res://scenes/room_screen/room_screen.tscn")
var selected_numbers

func show():
	visible = true
	$SelectPanel.visible = true
	$InfoPanel.visible = false
	$InfoStatusPanel.visible = false
	$SelectPanel/NumberGrid/Numpad.numbers = []

func _on_back_button_pressed():
	visible = false

func _reset_select_panel():
	$SelectPanel/NumberGrid/Numpad.readonly = false
	$SelectPanel/BackButton.visible = true
	$SelectPanel/Status.visible = false
	$SelectPanel/NumberGrid/Numpad.numbers = []

func _on_numpad_completed(numbers):
	$SelectPanel/BackButton.visible = false
	
	$SelectPanel/Status.visible = true
	$SelectPanel/Status.text = "searching for room ..."
	$SelectPanel/NumberGrid/Numpad.readonly = true
	
	var result = yield(driver.remote_call("search_room", [numbers]), "result")
	
	if result.status == "ok":
		var info = result.info
		
		selected_numbers = numbers
		_reset_select_panel()
		$SelectPanel.visible = false
		
		
		$InfoPanel.visible = true
		$InfoPanel/Margin/Vertical/Title.text = info.title
		$InfoPanel/Margin/Vertical/Description.text = info.description
		$InfoPanel/Margin/Vertical/Info.text = "Created by %s, %s/%s" % [info.owner, info.size, info.capacity]
		
	else:
		$SelectPanel/Status.text = "room not found"

		yield(get_tree().create_timer(1), "timeout")
		_reset_select_panel()
	print(result)


func _on_infopanel_cancel_pressed():
	$InfoPanel.visible = false
	$SelectPanel.visible = true

	$InfoPanel/Margin/Vertical/Buttons/Cancel.disabled = false
	$InfoPanel/Margin/Vertical/Buttons/Join.disabled = false
	$InfoStatusPanel.visible = false

func _on_infopanel_join_pressed():
	$InfoPanel/Margin/Vertical/Buttons/Cancel.disabled = true
	$InfoPanel/Margin/Vertical/Buttons/Join.disabled = true
	var value = yield(driver.remote_call("join_room", [selected_numbers]), "result")
	
	if value.status == "ok":
		shared.data = value.info
		shared.data.players = value.players
		get_tree().change_scene_to(RoomScreen)
	else:
		var message
		match value.reason:
			"full":
				message = "The room is full already"
			
			"nonexist":
				message = "The game has started already"
				
			_:
				message = "Cannot join this room"
		
		$InfoStatusPanel.visible = true
		$InfoStatusPanel/Label.text = message
		yield(get_tree().create_timer(1.5), "timeout")
		_on_infopanel_cancel_pressed()
