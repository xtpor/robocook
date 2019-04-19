extends Spatial


func _ready():
	pass
	start()

func start():
	pass

const SPEED = 1

func set_player(p):
	$Robot.player_no = p
 
func set_robot(r):
	$Robot.robot_no = r

func _on_ButtonWalk_pressed():
	$Robot.move_forward(SPEED)

func _on_ButtonRotateLeft_pressed():
	$Robot.turn_left(SPEED)

func _on_ButtonRotateRight_pressed():
	$Robot.turn_right(SPEED)

func _on_ButtonPickUp_pressed():
	$Robot.pick_up(SPEED)

func _on_ButtonPutDown_pressed():
	$Robot.put_down(SPEED)

func _on_ButtonChop_pressed():
	$Robot.chop(SPEED)

func _on_ButtonCounter_pressed():
	$Robot.change_counter(SPEED)


func _on_ButtonMessage_pressed():
	print("show message")
	var TextPopup = preload("res://scenes/stage/text_popup/text_popup.tscn")
	var tp = TextPopup.instance()
	add_child(tp)
	tp.translation = Vector3(0, 2.4, 0)
	tp.initialize(1, "sameple message\nplus new line")
	
