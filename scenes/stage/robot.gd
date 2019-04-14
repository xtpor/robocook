extends Spatial


var player_no setget set_player_no, get_player_no
var robot_no setget set_robot_no, get_robot_no
var eye setget set_eye, get_eye
var dir setget set_dir, get_dir

var _player_no = 0
var _robot_no = 0
var _eye = true
var _dir = [0, 1]

var _gender = "male"
var _color = "red"
var _eye_position = "left"



func _ready():
	pass # Replace with function body.

func move_forward():
	$AnimationPlayer.play("walking")
	yield($AnimationPlayer, "animation_finished")
	_reset()

	translate_object_local(Vector3(0, 0, 1))

func turn_left():
	$AnimationPlayer.play("turn_left")
	yield($AnimationPlayer, "animation_finished")
	_reset()
	rotation_degrees.y += 90

func turn_right():
	$AnimationPlayer.play("turn_right")
	yield($AnimationPlayer, "animation_finished")
	_reset()
	rotation_degrees.y += -90


func get_dir():
	return _dir

func set_dir(value):
	_dir = value
	match _dir:
		[0.0, 1.0]:
			rotation_degrees.y = 0
		[0.0, -1.0]:
			rotation_degrees.y = 180
		[1.0, 0.0]:
			rotation_degrees.y = 90
		[-1.0, 0.0]:
			rotation_degrees.y = -90
		_:
			assert(false)

func get_robot_no():
	return _robot_no
	
func set_robot_no(robot_no):
	_robot_no = robot_no
	_gender = "male" if robot_no <= 3 else "female"
	_apply_change()
	
func get_player_no():
	return _player_no

func set_player_no(player_no):
	_player_no = player_no
	_color = ["red", "green", "blue", "yellow"][player_no]
	_apply_change()

func get_eye():
	return _eye

func set_eye(is_left):
	_eye = is_left
	_eye_position = "left" if is_left else "right"
	_apply_change()


func _reset():
	$MainAxis.translation = Vector3()
	$MainAxis/Hat.rotation = Vector3()
	$MainAxis/Head.rotation = Vector3()
	$MainAxis/Body.rotation = Vector3()
	$MainAxis/RightHandAxis.rotation = Vector3()
	$MainAxis/LeftHandAxis.rotation = Vector3()
	$MainAxis/RightFootAxis.rotation = Vector3()
	$MainAxis/LeftFootAxis.rotation = Vector3()

func _apply_change():
	_set_hat(_gender, _color)
	_set_head(_gender, _eye_position)
	_set_body(_gender)

func _set_hat(gender, color):
	for ch in $MainAxis/Hat.get_children():
		ch.visible = false
	get_node("MainAxis/Hat/hat_%s_%s" % [gender, color]).visible = true

func _set_head(gender, eyes_pos):
	for ch in $MainAxis/Head.get_children():
		ch.visible = false
	get_node("MainAxis/Head/head_%s_eyes_%s" % [gender, eyes_pos]).visible = true

func _set_body(gender):
	for ch in $MainAxis/Body.get_children():
		ch.visible = false
	get_node("MainAxis/Body/body_%s" % [gender]).visible = true


func _on_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			print("robot.gd: on mouse down")
		else:
			print("robot.gd: on mouse up")


func _on_mouse_entered():
	print("robot.gd: on mouse enter")

func _on_mouse_exited():
	print("robot.gd: on mouse exit")
