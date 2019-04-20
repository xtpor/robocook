extends Control

const SPEEDS = ["slow", "normal", "fast", "very_fast"]
const SPEED_NAMES = ["slow", "normal", "fast", "very fast"]
const SPEED_MULTIPLIERS = {"slow": 0.5, "normal": 1, "fast": 2, "very_fast": 4}


var MenuScreen = load("res://scenes/menu_screen/menu_screen.tscn")

var info
var current_speed = 1

var stage
var editor

func _ready():
	info = shared.data
	
	driver.connect("event_received", self, "_on_network_event")
	
	# Initialize the info pane
	$MainWindow/EditorPane/Left/LevelInfoPane.set_title(info.title)
	$MainWindow/EditorPane/Left/LevelInfoPane.set_description(info.description)
	$MainWindow/EditorPane/Left/LevelInfoPane.set_goal(info.goal)
	
	# Set up the scene and robot mapping
	stage = $MainWindow/GameView/ViewportContainer/Viewport/Stage
	stage.initialize(info)
	stage.build_scene(0)
	
	# set up the block editor
	editor = $MainWindow/EditorPane/Left/BlockEditor
	editor.initialize(info)
	editor.connect("code_changed", self, "_on_code_changed")
	editor.connect("robot_selected", self, "_on_robot_selected")
	
	# Setup robot initial marker
	stage.select_robot(editor.selected_robot)

func _on_network_event(ename, edata):
	match ename:
		"text_sent":
			$MainWindow/GameView/HUD/EventsMargin/Events.add_chat_event(edata)
		
		"emoji_sent":
			$MainWindow/GameView/HUD/EventsMargin/Events.add_emoji_event(edata)
		
		"speed_changed":
			_on_speed_changed(edata)
		
		"code_changed":
			editor.set_ast(edata.robot, edata.ast)
		
		"scene_played":
			$MainWindow/GameView/HUD/Margin/Buttons/ButtonPlay.disabled = true
			$MainWindow/GameView/HUD/Margin/Buttons/ButtonPause.disabled = false
			$MainWindow/GameView/HUD/Margin/Buttons/ButtonStop.disabled = false
			editor.set_readonly(true)
			stage.hide_marker()
			
			var scene_no = edata
			print("game_screen.gd: play the scene %s" % [scene_no])
			stage.build_scene(scene_no)
		
		"scene_stopped":
			$MainWindow/GameView/HUD/Margin/Buttons/ButtonPlay.disabled = false
			$MainWindow/GameView/HUD/Margin/Buttons/ButtonPause.disabled = true
			$MainWindow/GameView/HUD/Margin/Buttons/ButtonStop.disabled = true
			editor.set_readonly(false)
			stage.unhide_marker()
		
		"scene_paused":
			$MainWindow/GameView/HUD/Margin/Buttons/ButtonPlay.disabled = false
			$MainWindow/GameView/HUD/Margin/Buttons/ButtonPause.disabled = true
			$MainWindow/GameView/HUD/Margin/Buttons/ButtonStop.disabled = false
			editor.set_readonly(true)
			stage.hide_marker()
		
		"game_tick":
			_on_game_tick(edata)
		
		"game_result":
			if edata.primary == "complete":
				$CompletionPopup.initialize(info.goal, edata)
			else:
				var e = {"goal": info.goal, "status": edata}
				$MainWindow/GameView/HUD/EventsMargin/Events.add_game_failure_event(e)
			
		_:
			print("Unhandled event %s" % [ename])

func _on_robot_selected(robot_no):
	print("game_screen.gd: selected robot %s" % [robot_no])
	stage.select_robot(robot_no)

func _on_game_tick(e):
	for update in e.updates:
		match update:
			{"type": "action", "action": "move_forward", ..}:
				stage.robot_move_forward(update.no)
			{"type": "action", "action": "turn_left", ..}:
				stage.robot_turn_left(update.no)
			{"type": "action", "action": "turn_right", ..}:
				stage.robot_turn_right(update.no)
			{"type": "action", "action": "pick_up", "log": {"type": "pick_item", ..}, ..}:
				stage.robot_pick_item(update.no, update.log.target_pos)
			{"type": "action", "action": "pick_up", "log": {"type": "pick_source", ..}, ..}:
				stage.robot_pick_source(update.no, update.log.holding)
			{"type": "action", "action": "put_down", "log": {"type": "put_item", ..}, ..}:
				stage.robot_put_item(update.no, update.log.target_pos, update.log.holding, update.log.target_item)
			{"type": "action", "action": "put_down", "log": {"type": "drained", ..}, ..}:
				stage.robot_drain_item(update.no, update.log.holding)
			{"type": "action", "action": "put_down", "log": {"type": "delivered", ..}, ..}:
				stage.robot_deliver_item(update.no)
			{"type": "action", "action": "chop", ..}:
				stage.robot_chop_item(update.no, update.log.target_pos, update.log.target_item)
			{"type": "action", "action": ["increment", _], ..}:
				stage.robot_update_counter(update.no, update.log.new_count)
			{"type": "action", "action": ["decrement", _], ..}:
				stage.robot_update_counter(update.no, update.log.new_count)
			# Handle error
			{"type": "action_error", ..}:
				match update.action:
					"move_forward":
						stage.robot_show_error(update.no, "Robot %s: Cannot move forward" % [update.no + 1])
					"pick_up":
						stage.robot_show_error(update.no, "Robot %s: Cannot pick up" % [update.no + 1])
					"put_down":
						stage.robot_show_error(update.no, "Robot %s: Cannot put down" % [update.no + 1])
					"chop":
						stage.robot_show_error(update.no, "Robot %s: Cannot chop this item" % [update.no + 1])
					["increment", _]:
						stage.robot_show_error(update.no, "Robot %s: Cannot increment counter" % [update.no + 1])
					["decrement", _]:
						stage.robot_show_error(update.no, "Robot %s: Cannot decrement counter" % [update.no + 1])
					_:
						assert(false)
			{"type": "robot_error", "reason": "instruction_limit", ..}:
				stage.robot_show_error(update.no, "Robot %s: Stuck in a infinite loop" % [update.no + 1])
			{"type": "robot_error", "reason": "stack_limit", ..}:
				stage.robot_show_error(update.no, "Robot %s: Stack overflow error" % [update.no + 1])
			_:
				print("Unhandled game update %s" % [update])

func _on_code_changed(robot_no, ast):
	print("game_screen.gd: robot %s code changed, %s" % [robot_no, ast])
	driver.remote_cast("update_code", [robot_no, ast])

func _on_speed_button_pressed():
	var next_speed = (current_speed + 1) % SPEEDS.size()
	driver.remote_cast("change_speed", [SPEEDS[next_speed]])

func _on_speed_changed(new_speed):
	current_speed = SPEEDS.find(new_speed)
	$MainWindow/GameView/HUD/Margin/Buttons/SpeedButton.text = "speed: %s" % [SPEED_NAMES[current_speed]]
	stage.set_speed(SPEED_MULTIPLIERS[new_speed])

func _on_button_play_pressed():
	driver.remote_cast("play_scene", [])

func _on_button_pause_pressed():
	driver.remote_cast("pause_scene", [])

func _on_button_stop_pressed():
	driver.remote_cast("stop_scene", [])

func _on_completion_popup_pressed():
	get_tree().change_scene_to(MenuScreen)
