extends Control

var Chapter = preload("./chapter.tscn")
var RoomScreen = preload("res://scenes/room_screen/room_screen.tscn")

var my_title
var my_point_gathered
var chapters


var selected_level_ref

func _ready():
	$MainPanel/StatusBar/PlayerInfo/Name.text = "Name: %s" % [credentials_store.username]
	
	$LoadPanel.visible = true
	$LoadPanel/Panel/Label.text = "loading player info ..."
	
	my_title = yield(driver.remote_call("get_title", []), "result")
	$MainPanel/StatusBar/PlayerInfo/Title.text = "Title: %s" % [my_title]
	
	my_point_gathered = yield(driver.remote_call("points_gathered", []), "result")
	$MainPanel/StatusBar/PlayerInfo/Points.text = "Points: %s" % [my_point_gathered]

	$LoadPanel/Panel/Label.text = "loading levels ..."
	chapters = yield(driver.remote_call("list_chapters", null), "result")
	for chapter in chapters:
		var value = yield(driver.remote_call("list_levels", [chapter.ref]), "result")
		chapter.levels = value.result
	
	$LoadPanel.visible = false
	
	# Build the chapter GUI
	for chapter in chapters:
		var chobj = Chapter.instance()
		chobj.init(chapter)
		chobj.connect("level_selected", self, "_on_level_selected")
		$MainPanel/Chapters/Vertical.add_child(chobj)

func _on_level_selected(level):
	selected_level_ref = level.ref

	$LevelPanel.visible = true
	$LevelPanel/Panel/Margin/Vertical/LevelName.text = level.title
	$LevelPanel/Panel/Margin/Vertical/IsMultiplayer.text = "multiplayer: %s" % ["Yes" if level.multiplayer else "No"]
	

func _on_cancel_level_pressed():
	$LevelPanel.visible = false

func _on_multiplayer_button_pressed():
	$MultiplayerPanel.show()

func _on_start_level_pressed():
	# TODO: handle singleplayer

	var value = yield(driver.remote_call("create_room", [selected_level_ref]), "result")
	assert(value.status == "ok")
	shared.data = value.info
	shared.data.players = [value.info.owner]
	var _err = get_tree().change_scene_to(RoomScreen)

