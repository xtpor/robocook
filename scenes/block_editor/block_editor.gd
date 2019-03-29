extends Control

var EditorProcedure = preload("./editor_procedure.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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