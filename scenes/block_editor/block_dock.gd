extends PanelContainer

const MAPPING = [
	["move_forward", "LabelActions", "ItemMoveForward"],
	["turn_left", "LabelActions", "ItemTurnLeft"],
	["turn_right", "LabelActions", "ItemTurnRight"],
	["pick_up", "LabelActions", "ItemPickUp"],
	["put_down", "LabelActions", "ItemPutDown"],
	["chop", "LabelActions", "ItemChop"],
	["increment", "LabelActions", "ItemIncrement"],
	["decrement", "LabelActions", "ItemDecrement"],
	["wait", "LabelActions", "ItemWait"],
	["if", "LabelBranching", "ItemIf"],
	["if_else", "LabelBranching", "ItemIfElse"],
	["loop", "LabelLooping", "ItemLoop"],
	["repeat", "LabelLooping", "ItemRepeat"],
	["while", "LabelLooping", "ItemWhile"],
	["halt", "LabelSpecial", "ItemHalt"],
	["call", "LabelSpecial", "ItemCall"],
]

func set_availble_blocks(list):
	print("block_dock.gd: set_available_blocks %s" % [list])
	for entry in MAPPING:
		$Scroll/Margin/Items.get_node(entry[1]).visible = false
		$Scroll/Margin/Items.get_node(entry[2]).visible = false

	for item in list:
		var entry = null
		for e in MAPPING:
			if e[0] == item:
				entry = e
				break
		if entry != null:
			$Scroll/Margin/Items.get_node(entry[1]).visible = true
			$Scroll/Margin/Items.get_node(entry[2]).visible = true

func set_readonly(b):
	$CoverPanel.visible = b
