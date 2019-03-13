extends VBoxContainer

var CodeBlock = preload("./blocks/code_block.gd")
var BlockListEntry = preload("./block_list_entry.tscn")


var _target = null
var _dropped = false

func init(blocks):
	var indent = 0
	
	for block in blocks:
		var entry = BlockListEntry.instance()
		
		if block.indent_mode in [CodeBlock.IndentMode.OUT, CodeBlock.IndentMode.INOUT]:
			indent -= 1
			
		entry.add_child(block)
		entry.get_node("Indent").rect_min_size.x = 15 * indent
		
		if block.indent_mode in [CodeBlock.IndentMode.IN, CodeBlock.IndentMode.INOUT]:
			indent += 1
		
		add_child(entry)

func drop():
	if _dropped:
		return
	
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "block_receiver", "prepare_receive", self)
	if _target != null:
		var blks = _extract_blocks()
		_target.receive(blks)
	
	get_tree().call_group("block_target", "enable_drop_hint", false)
	get_parent().remove_child(self)
	queue_free()
	_dropped = true

func set_receive_target(entity):
	_target = entity

func _extract_blocks():
	var blocks = []
	for entry in get_children():
		var block = entry.get_child(1)
		entry.remove_child(block)
		blocks.append(block)
	return blocks

func _ready():
	get_tree().call_group("block_target", "enable_drop_hint", true)

func _process(delta):
	rect_global_position = get_global_mouse_position() - Vector2(10, 10)