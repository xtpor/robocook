extends HBoxContainer

signal remove()
signal add()


var operators = ["and", "or"]
var _options_added = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_add_options()
	reflow()

func _add_options():
	if not _options_added:
		for op in operators:
			$BooleanButton.add_item(op)
	_options_added = true

func _on_remove_button_pressed():
	emit_signal("remove")

func _on_add_button_pressed():
	emit_signal("add")
	
func reflow():
	var is_last = get_index() == $"..".get_child_count() - 1
	$BooleanButton.visible = not is_last
	$RemoveButton.visible = not is_last
	$AddButton.visible = is_last

func serialize_operator():
	return $BooleanButton.get_item_text($BooleanButton.selected)

func serialize_condition():
	return $ConditionBody.serialze()

func deserialize_operator(op):
	_add_options()
	$BooleanButton.select(operators.find(op))

func deserialize_condition(cond):
	$ConditionBody.deserialize(cond)