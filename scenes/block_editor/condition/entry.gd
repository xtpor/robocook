extends HBoxContainer

signal remove()
signal add()

# Called when the node enters the scene tree for the first time.
func _ready():
	$BooleanButton.add_item("and")
	$BooleanButton.add_item("or")
	reflow()

func reflow():
	var is_last = get_index() == $"..".get_child_count() - 1
	$BooleanButton.visible = not is_last
	$RemoveButton.visible = not is_last
	$AddButton.visible = is_last

func _on_remove_button_pressed():
	emit_signal("remove")


func _on_add_button_pressed():
	emit_signal("add")
