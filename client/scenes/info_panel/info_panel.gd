extends ColorRect


signal close()

var _i
var _list
var _content = null

func set_panel_list(list):
	visible = true
	_i = 0
	_list = list
	load_info(_list[_i])
	update_buttons()

func load_info(info_name):
	if _content != null:
		_content.visible = false
		_content.queue_free()
	
	var Content = load("res://scenes/info_panel/panels/%s.tscn" % [info_name])
	assert(Content != null)
	_content = Content.instance()
	$Panel.add_child(_content)
	
func update_buttons():
	$Panel/ButtonPrev.disabled = not _i > 0
	$Panel/ButtonNext.disabled = not _i < _list.size() - 1


func _on_button_prev_pressed():
	_i -= 1
	load_info(_list[_i])
	update_buttons()

func _on_button_next_pressed():
	_i += 1
	load_info(_list[_i])
	update_buttons()

func _on_button_close_pressed():
	emit_signal("close")
