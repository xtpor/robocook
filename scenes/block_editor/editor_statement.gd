extends VBoxContainer


signal receive_blocks(blocks, index)
signal block_selected_first()
signal block_selected_last()
signal block_unselected()

const INDENT_SIZE = 15

var CodeBlock = preload("./blocks/code_block.gd")

var _drop_hint = false
var _is_mouse_inside = false


func set_block(b):
	$Margin/Main.add_child(b)
	b.connect("block_selected_first", self, "_on_block_selected_first")
	b.connect("block_selected_last", self, "_on_block_selected_last")
	b.connect("block_unselected", self, "_on_block_unselected")
	b._on_insert()

func get_block():
	if $Margin/Main.get_child_count() == 3:
		return $Margin/Main.get_child(2)
	else:
		return null

func remove_block():
	var blk = get_block()
	assert(blk != null)
	
	blk._on_delete()
	blk.disconnect("block_selected_first", self, "_on_block_selected_first")
	blk.disconnect("block_selected_last", self, "_on_block_selected_last")
	blk.disconnect("block_unselected", self, "_on_block_unselected")
	$Margin/Main.remove_child(blk)

	return blk

func set_line_no(no):
	$Margin/Main/LineNumber.text = "%02d" % [no]

func set_indent(level):
	var bar_level = level
	if get_block() != null and get_block().indent_mode in [CodeBlock.IndentMode.OUT, CodeBlock.IndentMode.INOUT]:
		bar_level += 1
	$InsertBar/Indentation.rect_min_size.x = INDENT_SIZE * bar_level
	$Margin/Main/Indentation.rect_min_size.x = INDENT_SIZE * level


func enable_drop_hint(b):
	_drop_hint = b

func prepare_receive(block_list):
	if _is_mouse_inside:
		block_list.set_receive_target(self)

# Callback function called by block list
func receive(blocks):
	emit_signal("receive_blocks", blocks, get_index())


func _ready():
	pass # Replace with function body.

func _process(delta):
	_is_mouse_inside = _check_mouse_inside()
	
	$InsertBar/Bar.visible = _is_mouse_inside if _drop_hint else false


func _check_mouse_inside():
	return _point_within_entity(self, get_global_mouse_position())

func _point_within_entity(node, point):
	if node is Control:
		if !node.get_global_rect().has_point(point):
			return false
	
	var parent = node.get_node_or_null("..")
	if parent == null:
		return true
	else:
		return _point_within_entity(parent, point)

func _on_block_selected_first():
	emit_signal("block_selected_first")

func _on_block_selected_last():
	emit_signal("block_selected_last")

func _on_block_unselected():
	emit_signal("block_unselected")