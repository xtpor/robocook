extends Control

signal code_changed(robot, ast)

const WARNING_MESSAGE = "Warning: This robot is controlled by player %s, modification to the code below will be overwritten."

var EditorProcedure = preload("./editor_procedure.tscn")

var player
var controls
var asts
var robot_count = 0
var selected_robot = 0

var _snapshot = null

# Public method

func initialize(params):
	assert(params.controls.size() == params.asts.size())
	player = params.player
	controls = params.controls
	asts = params.asts
	robot_count = asts.size()
	
	# Select the first robot that is controlled by player
	var selected = 0
	for p in range(robot_count):
		if controls[p] == player:
			selected = p
			break
	
	select_robot(selected)

func select_robot(r):
	# Select the robot and display its ast on the editor
	
	var ast = asts[r]
	deserialize(ast)
	$Margin/Scroll/Items/Top/EditorHeading/RobotName.text = "Robot %s" % [r + 1]
	$Margin/Scroll/Items/Top/EditorHeading/ButtonPrev.disabled = not valid_robot_no(r - 1)
	$Margin/Scroll/Items/Top/EditorHeading/ButtonNext.disabled = not valid_robot_no(r + 1)
	selected_robot = r
	
	# display a warning message if player do not control the robot
	if controls[r] == player:
		$Margin/Scroll/Items/Top/WarningLabel.visible = false
	else:
		$Margin/Scroll/Items/Top/WarningLabel.visible = true
		$Margin/Scroll/Items/Top/WarningLabel.text = WARNING_MESSAGE % [controls[r] + 1]

func check_for_changes():
	# Check for changes and emit a signal when code has changed
	_serialize_selection()
	var current = _snapshot_asts()
	
	if _snapshot != null:
		for i in range(robot_count):
			if current[i] != _snapshot[i]:
				emit_signal("code_changed", i, asts[i])

	_snapshot = _snapshot_asts()

func set_ast(r, new_ast):
	asts[r] = new_ast
	
	# Show the changes immediately if the code updated is
	# currently view by the player. However, if the robot
	# is controlled by the player, we would not update the UI
	# in order to prevent UI from jittering
	if selected_robot == r and controls[r] != player:
		# First drop the block to prevent it from interfere with
		# the deserialization
		get_tree().call_group("block_list", "drop_abort")
		deserialize(asts[r])

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_loop()
	
func _update_loop():
	# WARNING: This is a hack
	# In order to detect changes to the code and send update
	# to server, there is a loop that check for changes every
	# 0.5 seconds. This method is probably resource intensive
	# and require manual checking when playing the scene 
	var interval = 0.5
	yield(get_tree(), "idle_frame")
	while true:
		check_for_changes()
		yield(get_tree().create_timer(interval), "timeout")

func _serialize_selection():
	if controls[selected_robot] == player:
		asts[selected_robot] = serialize()

func _snapshot_asts():
	var ss = []
	for ast in asts:
		ss.append(var2str(ast))
	return ss

func _on_prev_pressed():
	_serialize_selection()
	select_robot(selected_robot - 1)

func _on_next_pressed():
	_serialize_selection()
	select_robot(selected_robot + 1)

func _on_new_procedure_pressed():
	_add_procedure()

func _on_delete_procedure(proc):
	$Margin/Scroll/Items.remove_child(proc)
	reflow()

	# Notify the blocks in the editor
	get_tree().call_group("block_call", "procedure_changed")

func _add_procedure():
	var proc = EditorProcedure.instance()
	proc.readonly = not get_procedure_count() > 0
	proc.connect("delete", self, "_on_delete_procedure", [proc])
	$Margin/Scroll/Items.add_child(proc)
	reflow()

	# Notify the blocks in the editor
	get_tree().call_group("block_call", "procedure_changed")

func get_procedure_count():
	return $Margin/Scroll/Items.get_child_count() - 1

func reflow():
	var i = 0
	for i in get_procedure_count():
		var proc = $Margin/Scroll/Items.get_child(i + 1)
		if i == 0:
			proc.set_title("Main Procedure")
		else:
			proc.set_title("Procedure %s" % [i])

func get_procedure(i):
	return $Margin/Scroll/Items.get_child(i + 1)

func clear():
	while $Margin/Scroll/Items.get_child_count() > 1:
		var child = $Margin/Scroll/Items.get_child(1)
		$Margin/Scroll/Items.remove_child(child)
		child.queue_free()

func serialize():
	var result = []
	for i in range(get_procedure_count()):
		var proc = $Margin/Scroll/Items.get_child(i + 1)
		result.append(["procedure", i, proc.serialize()])
	return result

func deserialize(ast):
	clear()
	for _index in range(ast.size()):
		_add_procedure()
	for i in range(ast.size()):
		var ast_procedure = ast[i]
		var ast_statements = ast_procedure[2]
		get_procedure(i).deserialize(ast_statements)

func set_readonly(b):
	$CoverPanel.visible = b
	get_tree().call_group("block_list", "drop_abort")

func valid_robot_no(r):
	return 0 <= r and r < robot_count