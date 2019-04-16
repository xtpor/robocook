extends Control

const SPEEDS = ["slow", "normal", "fast", "very_fast"]
const SPEED_NAMES = ["slow", "normal", "fast", "very fast"]

var info
var current_speed = 1


var editor

func _ready():
	info = shared.data
	
	driver.connect("event_received", self, "_on_network_event")
	
	# Initialize the info pane
	$MainWindow/EditorPane/Left/LevelInfoPane.set_title(info.title)
	$MainWindow/EditorPane/Left/LevelInfoPane.set_description(info.description)
	$MainWindow/EditorPane/Left/LevelInfoPane.set_goal(info.goal)
	
	var first_scene = info.scenes[0]
	$MainWindow/GameView/ViewportContainer/Viewport/Stage.build_scene(first_scene)
	
	# set up the block editor
	editor = $MainWindow/EditorPane/Left/BlockEditor
	editor.initialize(info)
	editor.connect("code_changed", self, "_on_code_changed")

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
			
		_:
			print("Unhandled event %s" % [ename])

func _on_code_changed(robot_no, ast):
	print("game_screen.gd: robot %s code changed, %s" % [robot_no, ast])
	driver.remote_cast("update_code", [robot_no, ast])

func _on_speed_button_pressed():
	var next_speed = (current_speed + 1) % SPEEDS.size()
	driver.remote_cast("change_speed", [SPEEDS[next_speed]])

func _on_speed_changed(new_speed):
	current_speed = SPEEDS.find(new_speed)
	$MainWindow/GameView/HUD/Margin/Buttons/SpeedButton.text = "speed: %s" % [SPEED_NAMES[current_speed]]