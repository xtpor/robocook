extends HBoxContainer


var variations = [
	{"name": "tile", "node": preload("./tile_type.tscn")},
	{"name": "item", "node": preload("./item_type.tscn")},
	{"name": "counter", "node": preload("./counter_type.tscn")}
]

var item_added = false
var last_selected = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if not item_added:
		_add_item()

func _add_item():
	$Type.add_item("...")
	for v in variations:
		$Type.add_item(v.name)
	item_added = true

func select_item(selected):
	if last_selected != selected:
		remove_extra()
	
	if selected != 0:
		var node = variations[selected - 1].node.instance()
		add_child(node)
	
	last_selected = selected

func remove_extra():
	if is_type_selected():
		var ch = get_child(1)
		remove_child(ch)
		ch.queue_free()

func is_type_selected():
	return get_child_count() > 1

func serialze():
	if is_type_selected():
		return get_child(1).serialize()
	else:
		return ["const", true]

func deserialize(cond):
	_add_item()
	match cond:
		["const", true]:
			pass

		["test", ["is_tile", _]]:
			$Type.select(1)
			select_item(1)
			get_child(1).deserialize(cond)
			
		["not", ["test", ["is_tile", _]]]:
			$Type.select(1)
			select_item(1)
			get_child(1).deserialize(cond)
			
		["test", ["is_item", _]]:
			$Type.select(2)
			select_item(2)
			get_child(1).deserialize(cond)
			
		["not", ["test", ["is_item", _]]]:
			$Type.select(2)
			select_item(2)
			get_child(1).deserialize(cond)
			
		["test", ["check_counter", _, _]]:
			$Type.select(3)
			select_item(3)
			get_child(1).deserialize(cond)