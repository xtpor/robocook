extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	# $Robot/AnimationPlayer.play("walking")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_player(p):
	$Robot.player_no = p
 
func set_robot(r):
	$Robot.robot_no = r

func _on_ButtonWalk_pressed():
	$Robot.move_forward()

func _on_ButtonRotateLeft_pressed():
	$Robot.turn_left()

func _on_ButtonRotateRight_pressed():
	$Robot.turn_right()
