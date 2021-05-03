extends VBoxContainer


signal delete()

var CodeBlock = preload("./blocks/code_block.gd")
var EditorStatement = preload("./editor_statement.tscn")
var BlockList = preload("./block_list.tscn")


var BlockMoveForward = load("res://scenes/block_editor/blocks/block_move_forward.tscn")
var BlockTurnLeft = load("res://scenes/block_editor/blocks/block_turn_left.tscn")
var BlockTurnRight = load("res://scenes/block_editor/blocks/block_turn_right.tscn")
var BlockPickUp = load("res://scenes/block_editor/blocks/block_pick_up.tscn")
var BlockPutDown = load("res://scenes/block_editor/blocks/block_put_down.tscn")
var BlockChop = load("res://scenes/block_editor/blocks/block_chop.tscn")
var BlockIncrement = load("res://scenes/block_editor/blocks/block_increment.tscn")
var BlockDecrement = load("res://scenes/block_editor/blocks/block_decrement.tscn")
var BlockWait = load("res://scenes/block_editor/blocks/block_wait.tscn")

var BlockIf = load("res://scenes/block_editor/blocks/block_if.tscn")
var BlockElse = load("res://scenes/block_editor/blocks/block_else.tscn")
var BlockEndIf = load("res://scenes/block_editor/blocks/block_end_if.tscn")

var BlockLoop = load("res://scenes/block_editor/blocks/block_loop.tscn")
var BlockRepeat = load("res://scenes/block_editor/blocks/block_repeat.tscn")
var BlockWhile = load("res://scenes/block_editor/blocks/block_while.tscn")
var BlockEndLoop = load("res://scenes/block_editor/blocks/block_end_any_loop.tscn")

var BlockHalt = load("res://scenes/block_editor/blocks/block_halt.tscn")
var BlockCall = load("res://scenes/block_editor/blocks/block_call.tscn")


export (bool) var readonly = false

var statements = []
var selected_first = null
var selected_last = null


# Get the number of non-empty statement
func get_statement_count():
	return $Statements/Blocks.get_child_count() - 1

# Get the statement by index
func get_statement(i):
	return $Statements/Blocks.get_child(i)

func set_title(title):
	$Heading/Title.text = title

func set_readonly(b):
	$Heading/Button.disabled = b

func serialize_range(start, end):
	if end < start:
		return []
	
	var index = start
	var limit = end
	var ast_fragments = []

	while index <= limit:
		var blk1 = get_statement(index).get_block()
		var blk2 = blk1.get_last()
		var last = blk2.get_statement().get_index()
		
		ast_fragments.append(blk1.serialize())
		index = last + 1
	return ast_fragments

func serialize():
	return serialize_range(0, get_statement_count() - 1)

func deserialize(ast_statements):
	var blocks = []
	deserialize_list(blocks, ast_statements)
	
	# Remove the empty block from the procedure
	var empty = $Statements/Blocks.get_child(0)
	$Statements/Blocks.remove_child(empty)
	
	# Add the blocks result from the deserialize
	for blk in blocks:
		var stmt = _spawn_statement()
		$Statements/Blocks.add_child(stmt)
		stmt.set_block(blk)
	_reflow()
	
	# Add back the empty block
	$Statements/Blocks.add_child(empty)

func deserialize_list(blocks, ast_statements):
	for stmt in ast_statements:
		deserialize_stmt(blocks, stmt)

func deserialize_stmt(blocks, stmt):
	match stmt:
		# Actions
		["action", "move_forward"]:
			blocks.append(BlockMoveForward.instance())
		["action", "turn_left"]:
			blocks.append(BlockTurnLeft.instance())
		["action", "turn_right"]:
			blocks.append(BlockTurnRight.instance())
		["action", "pick_up"]:
			blocks.append(BlockPickUp.instance())
		["action", "put_down"]:
			blocks.append(BlockPutDown.instance())
		["action", "chop"]:
			blocks.append(BlockChop.instance())
		["action", ["increment", var n]]:
			var blk = BlockIncrement.instance()
			blk.set_counter(n)
			blocks.append(blk)
		["action", ["decrement", var n]]:
			var blk = BlockDecrement.instance()
			blk.set_counter(n)
			blocks.append(blk)
		["action", "wait"]:
			blocks.append(BlockWait.instance())
		
		# Branching
		["if", var condition, var stmts_t, var stmts_f]:
			if stmts_f.size() == 0:
				var block_if = BlockIf.instance()
				var block_end = BlockEndIf.instance()
				block_if.deserialize_condition(condition)
				_connect_blocks([block_if, block_end])
				blocks.append(block_if)
				deserialize_list(blocks, stmts_t)
				blocks.append(block_end)
			else:
				var block_if = BlockIf.instance()
				var block_else = BlockElse.instance()
				var block_end = BlockEndIf.instance()
				block_if.deserialize_condition(condition)
				_connect_blocks([block_if, block_else, block_end])
				blocks.append(block_if)
				deserialize_list(blocks, stmts_t)
				blocks.append(block_else)
				deserialize_list(blocks, stmts_f)
				blocks.append(block_end)
		
		# Looping
		["loop", var stmts]:
			var blk1 = BlockLoop.instance()
			var blk2 = BlockEndLoop.instance()
			_connect_blocks([blk1, blk2])
			blocks.append(blk1)
			deserialize_list(blocks, stmts)
			blocks.append(blk2)
		["repeat", var count, var stmts]:
			var blk_repeat = BlockRepeat.instance()
			var blk_end = BlockEndLoop.instance()
			blk_repeat.set_counter(count)
			_connect_blocks([blk_repeat, blk_end])
			blocks.append(blk_repeat)
			deserialize_list(blocks, stmts)
			blocks.append(blk_end)
		["while", var condition, var stmts]:
			var blk_while = BlockWhile.instance()
			var blk_end = BlockEndLoop.instance()
			blk_while.deserialize_condition(condition)
			_connect_blocks([blk_while, blk_end])
			blocks.append(blk_while)
			deserialize_list(blocks, stmts)
			blocks.append(blk_end)
		
		# Special
		["halt"]:
			blocks.append(BlockHalt.instance())
		["call", var id]:
			var blk = BlockCall.instance()
			blk.deserialize(id)
			blocks.append(blk)

		_:
			printerr("Cannot deserialize item %s" % [stmt])
			assert(false)

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

func _connect_blocks(items):
	for i in items.size() - 1:
		items[i].next = items[i + 1]
		items[i + 1].prev = items[i]