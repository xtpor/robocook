extends Spatial

var MODELS = {
	"plate": preload("res://scenes/stage/containers/plate.tscn"),
	"pan": preload("res://scenes/stage/containers/pan.tscn"),
	"bowl": preload("res://scenes/stage/containers/bowl.tscn"),
	"pot": preload("res://scenes/stage/containers/pot.tscn")
}

var pos = [0, 0]
var type setget set_type, get_type
var item setget set_item, get_item

var _type = "plate"


func get_type():
	return _type

func set_type(value):
	if value == _type:
		return
	_type = value
	
	# Preserve the item inside this container
	var node = null
	if get_item() != null:
		node = pop_item()
		
	# Delete the old container
	var inner = get_child(0)
	remove_child(inner)
	inner.queue_free()
	
	# Put the new container
	var new_inner = MODELS[_type].instance()
	add_child(new_inner)

	# Put the item back to the container
	if node != null:
		set_item(node)
	
func get_item():
	var holding = get_child(0).get_node("Holding")
	if holding.get_child_count() > 0:
		return holding.get_child(0)
	else:
		return null

func set_item(value):
	var holding = get_child(0).get_node("Holding")
	assert(holding.get_child_count() == 0)
	value.translation = Vector3()
	holding.add_child(value)

func pop_item():
	var holding = get_child(0).get_node("Holding")
	assert(holding.get_child_count() == 1)
	var value = holding.get_child(0)
	holding.remove_child(value)
	return value