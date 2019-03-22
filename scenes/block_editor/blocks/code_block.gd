extends PanelContainer


signal block_selected_first()
signal block_selected_last()
signal block_unselected()

enum IndentMode {IN, OUT, INOUT, NONE}

export (IndentMode) var indent_mode = IndentMode.NONE
export (Color) var fade_color

var next = null
var prev = null


# Callback function, called when this block is placed in the editor
func _on_insert():
	pass

# Callback function, called just before this block is being removed from the editor
func _on_delete():
	pass


func _on_mouse_entered():
	modulate = fade_color
	_find_first(self).emit_signal("block_selected_first")
	_find_last(self).emit_signal("block_selected_last")

func _on_mouse_exited():
	modulate = Color(1, 1, 1, 1)
	emit_signal("block_unselected")

func _find_first(block):
	if block.prev == null:
		return block
	else:
		return _find_first(block.prev)

func _find_last(block):
	if block.next == null:
		return block
	else:
		return _find_last(block.next)