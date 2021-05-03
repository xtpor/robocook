extends Spatial


signal action_completed()

var item setget set_item, get_item
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

func move_forward(speed):
	$AnimationPlayer.playback_speed = speed
	$AnimationPlayer.play("walking" if get_item() == null else "walking2")
	yield($AnimationPlayer, "animation_finished")
	_reset()

	translate_object_local(Vector3(0, 0, 1))
	emit_signal("action_completed")

func turn_left(speed):
	$AnimationPlayer.playback_speed = speed
	$AnimationPlayer.play("turn_left")
	yield($AnimationPlayer, "animation_finished")
	_reset()
	rotation_degrees.y += 90
	emit_signal("action_completed")

func turn_right(speed):
	$AnimationPlayer.playback_speed = speed
	$AnimationPlayer.play("turn_right")
	yield($AnimationPlayer, "animation_finished")
	_reset()
	rotation_degrees.y += -90
	emit_signal("action_completed")

func pick_up(speed):
	$AnimationPlayer.playback_speed = speed
	$AnimationPlayer.play("pick_up")
	yield($AnimationPlayer, "animation_finished")
	_reset()
	emit_signal("action_completed")

func put_down(speed):
	$AnimationPlayer.playback_speed = speed
	$AnimationPlayer.play("put_down")
	yield($AnimationPlayer, "animation_finished")
	_reset()
	emit_signal("action_completed")

func change_counter(speed):
	$AnimationPlayer.playback_speed = speed
	$AnimationPlayer.play("change_counter")
	yield($AnimationPlayer, "animation_finished")
	_reset()
	emit_signal("action_completed")

func chop(speed):
	$AnimationPlayer.playback_speed = speed
	$AnimationPlayer.play("chop")
	yield($AnimationPlayer, "animation_finished")
	_reset()
	emit_signal("action_completed")

func set_normal_posture():
	$MainAxis/RightHandAxis/RightHand.translation = Vector3(-0.407, 0.433, 0)
	$MainAxis/LeftHandAxis/LeftHand.translation = Vector3(0.407, 0.433, 0)

func set_holding_posture():
	$MainAxis/RightHandAxis/RightHand.translation = Vector3(-0.407, 1.112, 1.002)
	$MainAxis/LeftHandAxis/LeftHand.translation = Vector3(0.407, 1.112, 1.007)


func set_item(node):
	assert(node != null)
	assert($MainAxis/ItemAxis/ItemHolding.get_child_count() == 0)
	node.translation = Vector3(0, 0, 0)
	$MainAxis/ItemAxis/ItemHolding.add_child(node)

func pop_item():
	var item = get_item()
	assert(item != null)
	$MainAxis/ItemAxis/ItemHolding.remove_child(item)
	return item

func get_item():
	if $MainAxis/ItemAxis/ItemHolding.get_child_count() > 0:
		return $MainAxis/ItemAxis/ItemHolding.get_child(0)
	else:
		return null

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

func set_marker(b):
	$ArrowMarker.visible = b



func _reset():
	$MainAxis.translation = Vector3()
	$MainAxis/Hat.rotation = Vector3()
	$MainAxis/Head.rotation = Vector3()
	$MainAxis/Body.rotation = Vector3()
	$MainAxis/RightHandAxis.rotation = Vector3()
	$MainAxis/LeftHandAxis.rotation = Vector3()
	$MainAxis/RightFootAxis.rotation = Vector3()
	$MainAxis/LeftFootAxis.rotation = Vector3()
	$MainAxis/ItemAxis.rotation = Vector3()

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
