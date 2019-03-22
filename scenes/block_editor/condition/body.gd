extends HBoxContainer


var variations = [
	{"name": "tile", "node": preload("./tile_type.tscn")},
	{"name": "item", "node": preload("./item_type.tscn")},
	{"name": "counter", "node": preload("./counter_type.tscn")}
]

var last_selected = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Type.add_item("...")
	for v in variations:
		$Type.add_item(v.name)

func _on_item_selected(selected):
	if last_selected != selected:
		remove_extra()
	
	if selected != 0:
		var node = variations[selected - 1].node.instance()
		add_child(node)
	
	last_selected = selected

func remove_extra():
	if get_child_count() > 1:
		var ch = get_child(1)
		remove_child(ch)
		ch.queue_free()