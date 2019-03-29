extends PanelContainer


signal block_selected_first()
signal block_selected_last()
signal block_unselected()

enum IndentMode {IN, OUT, INOUT, NONE}

enum BlockType {
	MOVE_FORWARD, TURN_LEFT, TURN_RIGHT, PICK_UP, PUT_DOWN, CHOP, INCREMENT, DECREMENT, WAIT,
	IF, ELSE,
	LOOP, REPEAT, WHILE,
	HALT, CALL,
	NONE
}

export (IndentMode) var indent_mode = IndentMode.NONE
export (Color) var fade_color = Color("#e9e9e9")
export (BlockType) var block_type = BlockType.NONE

var EditorStatement = load("res://scenes/block_editor/editor_statement.gd")


var next = null
var prev = null


# Get the parent statement, return null if this block is not attached to a statement
func get_statement():
	var parent = get_node_or_null(@"..")
	while not (parent == null or parent is EditorStatement):
		parent = parent.get_node_or_null(@"..")
	return parent

func get_first():
	return _get_first(self)

func get_last():
	return _get_last(self)

func serialize():
	match block_type:
		# Actions
		BlockType.MOVE_FORWARD:
			return ["action", "move_forward"]
		BlockType.TURN_LEFT:
			return ["action", "turn_left"]
		BlockType.TURN_RIGHT:
			return ["action", "turn_right"]
		BlockType.PICK_UP:
			return ["action", "pick_up"]
		BlockType.PUT_DOWN:
			return ["action", "put_down"]
		BlockType.CHOP:
			return ["action", "chop"]
		BlockType.INCREMENT:
			return ["action", ["increment", get_counter()]]
		BlockType.DECREMENT:
			return ["action", ["decrement", get_counter()]]
		BlockType.WAIT:
			return ["action", "wait"]
			
		# Branching
		BlockType.IF:
			if next.block_type == BlockType.ELSE:
				return ["if", serialize_condition(), serialize_between(self, next), serialize_between(next, next.next)]
			else:
				return ["if", serialize_condition(), serialize_between(self, next), []]
		
		# Looping
		BlockType.LOOP:
			return ["loop", serialize_between(self, next)]
		BlockType.REPEAT:
			return ["repeat", get_counter(), serialize_between(self, next)]
		BlockType.WHILE:
			return ["while", serialize_condition(), serialize_between(self, next)]
		
		# Special
		BlockType.HALT:
			return ["halt"]
		BlockType.CALL:
			return ["call", get_counter()]
			
		_:
			printerr("Cannot serialize the block type %s" % [block_type])
			assert(false)



# Callback function, called when this block is placed in the editor
func _on_insert():
	pass

# Callback function, called just before this block is being removed from the editor
func _on_delete():
	pass

func _on_mouse_entered():
	modulate = fade_color
	get_first().emit_signal("block_selected_first")
	get_last().emit_signal("block_selected_last")

func _on_mouse_exited():
	modulate = Color(1, 1, 1, 1)
	emit_signal("block_unselected")

func _get_first(block):
	if block.prev == null:
		return block
	else:
		return _get_first(block.prev)

func _get_last(block):
	if block.next == null:
		return block
	else:
		return _get_last(block.next)

func serialize_between(blk1, blk2):
	var i = blk1.get_statement().get_index()
	var j = blk2.get_statement().get_index()
	return get_statement().get_procedure().serialize_range(i + 1, j - 1)