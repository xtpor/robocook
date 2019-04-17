extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	# increment_counter()
	# $Robot/AnimationPlayer.play("walking")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# func increment_counter():
# 	for i in range(15):
# 		$Counter.set_count(i)
# 		yield(get_tree().create_timer(2.0), "timeout")

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
