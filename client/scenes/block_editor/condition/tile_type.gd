extends HBoxContainer

var tiles = ["floor", "table", "board", "stove", "delivery"]

var _options_added = false


func _ready():
	_add_options()

func _add_options():
	if not _options_added:
		$IsOption.add_item("is")
		$IsOption.add_item("is not")
		
		for t in tiles:
			$TileOption.add_item(t)
	_options_added = true

func serialize():
	var tile = tiles[$TileOption.selected]
	var result = ["test", ["is_tile", tile]]
	
	if $IsOption.selected == 1:
		result = ["not", result]
	return result

func deserialize(cond):
	_add_options()
	match cond:
		["not", var inner]:
			$IsOption.select(1)
			deserialize(inner)
		["test", ["is_tile", var tile]]:
			$TileOption.select(tiles.find(tile))