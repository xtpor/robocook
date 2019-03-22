extends HBoxContainer

func _ready():
	$IsOption.add_item("is")
	$IsOption.add_item("is not")

	$TileOption.add_item("floor")
	$TileOption.add_item("table")
	$TileOption.add_item("board")
	$TileOption.add_item("stove")