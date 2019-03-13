extends VBoxContainer


signal delete()

var CodeBlock = preload("./blocks/code_block.gd")
var EditorStatement = preload("./editor_statement.tscn")
var BlockList = preload("./block_list.tscn")

export (bool) var readonly = false

var statements = []
var selected_first = null
var selected_last = null


func set_title(title):
	$Heading/Title.text = title
	
func set_readonly(b):
	$Heading/Button.disabled = b

func _ready():
	set_readonly(readonly)
	
	var stmt = _spawn_statement()
	$Statements/Blocks.add_child(stmt)
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			if selected_first != null and selected_last != null:
				var start_index = selected_first.get_index()
				var last_index = selected_last.get_index()
				var items = _remove_blocks(start_index, last_index)
				
				var block_list = BlockList.instance()
				block_list.init(items)
				get_node("/root").add_child(block_list)
				
				selected_first = null
				selected_last = null
				_reflow()
		else:
			get_tree().call_group("block_list", "drop")


func _add_blocks(blocks, index):
	for block in blocks:
		var stmt = _spawn_statement()
		$Statements/Blocks.add_child(stmt)
		$Statements/Blocks.move_child(stmt, index)
		stmt.set_block(block)
		
		index += 1
	_reflow()

func _remove_blocks(index_start, index_last):
	var to_be_removed = []
	for i in range(index_start, index_last + 1):
		to_be_removed.append($Statements/Blocks.get_child(i))
	
	var blks = []
	for stmt in to_be_removed:
		$Statements/Blocks.remove_child(stmt)
		blks.append(stmt.remove_block())
		stmt.queue_free()
	return blks

func _spawn_statement():
	var stmt = EditorStatement.instance()
	stmt.connect("receive_blocks", self, "_on_receive_blocks")
	stmt.connect("block_selected_first", self, "_on_block_selected_first", [stmt])
	stmt.connect("block_selected_last", self, "_on_block_selected_last", [stmt])
	stmt.connect("block_unselected", self, "_on_block_unselected")
	return stmt

func _reflow():
	_reflow_line_no()
	_reflow_indentation()

func _reflow_line_no():
	var no = 1
	for child in $Statements/Blocks.get_children():
		child.set_line_no(no)
		no += 1

func _reflow_indentation():
	var indent = 0
	for child in $Statements/Blocks.get_children():
		var blk = child.get_block()
		if blk != null:
			if blk.indent_mode in [CodeBlock.IndentMode.OUT, CodeBlock.IndentMode.INOUT]:
				indent -= 1
			
			child.set_indent(indent)
			
			if blk.indent_mode in [CodeBlock.IndentMode.IN, CodeBlock.IndentMode.INOUT]:
				indent += 1

func _on_receive_blocks(blocks, index):
	_add_blocks(blocks, index)
	
func _on_block_selected_first(stmt):
	selected_first = stmt

func _on_block_selected_last(stmt):
	selected_last = stmt

func _on_block_unselected():
	selected_first = null
	selected_last = null


func _on_delete_button_pressed():
	emit_signal("delete")
