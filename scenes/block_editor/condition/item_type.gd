extends HBoxContainer


func _ready():
	$IsOption.add_item("is")
	$IsOption.add_item("is not")
	
	$ItemOption.add_item("apple")
	$ItemOption.add_item("orange")
	$ItemOption.add_item("banana")