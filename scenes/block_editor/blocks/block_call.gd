extends "./code_block.gd"


var BlockEditor = preload("../block_editor.gd")

func _ready():
	$Margin/Items/Options.add_item("...")
	
func _on_insert():
	print("Block call is being inserted into the editor")
	procedure_changed()

func procedure_changed():
	var selected_item = $Margin/Items/Options.selected
	var proc_count = _find_editor_node().get_procedure_count()
	
	$Margin/Items/Options.clear()
	$Margin/Items/Options.add_item("...")
	for i in range(1, proc_count):
		$Margin/Items/Options.add_item("procedure %s" % [i])
	
	if selected_item <= proc_count:
		$Margin/Items/Options.selected = selected_item

func _find_editor_node():
	var node = self
	while not node is BlockEditor:
		node = node.get_node("..")
	return node