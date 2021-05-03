extends Control

export (Color) var fade_color
export (Array, PackedScene) var blocks = []

var BlockList = preload("../block_list.tscn")


func _ready():
	pass # Replace with function body.

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			print("dock item: mouse down")
			
			var items = []
			for block in blocks:
				items.append(block.instance())
				
			# connect the blocks
			for i in items.size() - 1:
				items[i].next = items[i + 1]
				items[i + 1].prev = items[i]
			
			var block_list = BlockList.instance()
			block_list.init(items)
			
			get_node("/root").add_child(block_list)
		else:
			get_tree().call_group("block_list", "drop")

func _on_mouse_entered():
	modulate = fade_color

func _on_mouse_exited():
	modulate = Color(1, 1, 1, 1)