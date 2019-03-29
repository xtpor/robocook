extends HBoxContainer

var items = ["apple", "orange", "cookie"]

var _options_added = false


func _ready():
	_add_options()

func _add_options():
	if not _options_added:
		$IsOption.add_item("is")
		$IsOption.add_item("is not")
		
		for t in items:
			$ItemOption.add_item(t)
	_options_added = true

func serialize():
	var item = items[$ItemOption.selected]
	var result = ["test", ["is_item", item]]
	
	if $IsOption.selected == 1:
		result = ["not", result]
	return result

func deserialize(cond):
	_add_options()
	match cond:
		["not", var inner]:
			$IsOption.select(1)
			deserialize(inner)
		["test", ["is_item", var item]]:
			$ItemOption.select(items.find(item))