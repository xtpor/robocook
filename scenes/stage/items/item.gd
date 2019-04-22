extends Spatial

var MODELS = {
	["unknown", 0]: preload("res://scenes/stage/items/item_unknown.tscn"),
	["apple", 0]: preload("res://scenes/stage/items/carrot.tscn"),
	["tomato", 0]: preload("res://scenes/stage/items/tomato.tscn"),
	["chopped_tomato", 0]: preload("res://scenes/stage/items/chopped_tomato.tscn"),
}

var pos = [0, 0]
var type setget set_type, get_type
var stage setget set_stage, get_stage

var _type = "unknown"
var _stage = 0


func get_type():
	return _type

func set_type(value):
	_type = value
	_update_model()

func get_stage():
	return _stage

func set_stage(value):
	_stage = value
	_update_model()

func _update_model():
	var scene
	if MODELS.has([_type, _stage]):
		scene = MODELS[[_type, _stage]]
	elif MODELS.has([_type, 0]):
		scene = MODELS[[_type, 0]]
	else:
		print("item.gd: no model associated with %s:%s" % [_type, _stage])
		scene = MODELS[["unknown", 0]]
	
	_set_model(scene.instance())

func _set_model(node):
	# Remove any old model
	if get_child_count() >= 1:
		var old_node = get_child(0)
		remove_child(old_node)
		old_node.queue_free()
	
	# Set the new model
	add_child(node)