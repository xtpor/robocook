extends Control

const SPEEDS = ["slow", "normal", "fast", "very_fast"]
const SPEED_NAMES = ["slow", "normal", "fast", "very fast"]

var info
var current_speed = 1

func _ready():
	info = shared.data
	
	driver.connect("event_received", self, "_on_network_event")
	
	# Initialize the info pane
	$MainWindow/EditorPane/Left/LevelInfoPane.set_title(info.title)
	$MainWindow/EditorPane/Left/LevelInfoPane.set_description(info.description)
	$MainWindow/EditorPane/Left/LevelInfoPane.set_goal(info.goal)

func _on_network_event(ename, edata):
	match ename:
		"text_sent":
			$MainWindow/GameView/HUD/EventsMargin/Events.add_chat_event(edata)
		
		"emoji_sent":
			$MainWindow/GameView/HUD/EventsMargin/Events.add_emoji_event(edata)
		
		"speed_changed":
			_on_speed_changed(edata)
			
		_:
			print("Unhandled event %s" % [ename])

func _on_speed_button_pressed():
	var next_speed = (current_speed + 1) % SPEEDS.size()
	driver.remote_cast("change_speed", [SPEEDS[next_speed]])

func _on_speed_changed(new_speed):
	current_speed = SPEEDS.find(new_speed)
	$MainWindow/GameView/HUD/Margin/Buttons/SpeedButton.text = "speed: %s" % [SPEED_NAMES[current_speed]]