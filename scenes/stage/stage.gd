extends Spatial


var Robot = preload("./robot.tscn")
var Counter = preload("./counter/counter.tscn")
var Item = preload("./items/item.tscn")
var Container = preload("./containers/container.tscn")

var TextPopup = preload("./text_popup/text_popup.tscn")

var tile_mapping = {
	"void": preload("./tiles/void.tscn"),
	"floor": preload("./tiles/floor.tscn"),
	"wall": preload("./tiles/wall.tscn"),
	"table": preload("./tiles/table.tscn"),
	"drain": preload("./tiles/drain.tscn"),
	"source": preload("./tiles/source.tscn"),
	"delivery": preload("./tiles/delivery.tscn"),
	"board": preload("./tiles/board.tscn"),
	"stove": preload("./tiles/stove.tscn"),
	"oven": preload("./tiles/oven.tscn"),
	"mixer": preload("./tiles/mixer.tscn"),
	"display": preload("./tiles/display.tscn")
}

const ZOOM_MAP = {
	1: 5,
	2: 10,
	3: 10,
	4: 15,
	5: 15,
	6: 20,
	7: 25,
	8: 25,
	9: 30,
	10: 30,
	11: 35,
	12: 40,
	13: 40,
	14: 45,
	15: 45
}


var controls
var scenes
var selected_robot = null
var speed = 1


func initialize(params):
	controls = params.controls
	scenes = params.scenes

func build_scene(scene_id):
	# First drop all the node
	_reset_map()	
	
	var map = scenes[scene_id]
	var width = int(map.size[0])
	var height = int(map.size[1])
	
	for index in map.data.size():
		var i = index % width
		var j = index / width
		var entry = map.data[index]
		
		# Instantiate tile
		var tile = entry.tile
		var obj = tile_mapping[tile.type].instance()
		$Bases/Tiles.add_child(obj)
		obj.translation = Vector3(i, 0, j)
		
		# Tile variation handling
		if obj.has_node("Variation"):
			if tile.variation < obj.get_node("Variation").get_child_count():
				for nd in obj.get_node("Variation").get_children():
					nd.visible = false
				obj.get_node("Variation").get_child(tile.variation).visible = true

		# 'source' tile handling
		if tile.extra != null:
			var inner = _instance_entity([0, 0], tile.extra.item)
			inner.translation = Vector3()
			obj.get_node("Item").add_child(inner)
		
		# Instantiate entity
		if entry.entity != null:
			var entity = entry.entity
			if entity.type == "robot":
				var rbt = Robot.instance()
				$Bases/Robots.add_child(rbt)
		
				var no = entry.entity.no
				rbt.name = "Robot%s" % [no]
				rbt.robot_no = no
				rbt.player_no = controls[rbt.robot_no]
				rbt.dir = entry.entity.dir
				rbt.translation.x = i
				rbt.translation.z = j
				if entity.holding != null:
					rbt.item = _instance_entity([0, 0], entity.holding)
					rbt.set_holding_posture()
			else:
				var node = _instance_entity([i, j], entity)
				$Bases/Entities.add_child(node)
	
	var size = int(max(width, height))
	$Bases.translation.x = -((width - 1) / 2.0)
	$Bases.translation.z = -((height - 1) / 2.0)
	$CameraPod/Extender/Camera.translation.z = ZOOM_MAP[size]

func select_robot(r):
	deselect_robot()
	get_node("Bases/Robots/Robot%s" % [r]).set_marker(true)
	selected_robot = r

func deselect_robot(clear_selection = true):
	for rbt in $Bases/Robots.get_children():
		rbt.set_marker(false)
	
	if clear_selection:
		selected_robot = null

func hide_marker():
	deselect_robot(false)

func unhide_marker():
	if selected_robot != null:
		select_robot(selected_robot)

func set_speed(multiplier):
	speed = multiplier
	
# Action handlers

func robot_move_forward(robot_no):
	get_node("Bases/Robots/Robot%s" % [robot_no]).move_forward(speed)

func robot_turn_left(robot_no):
	get_node("Bases/Robots/Robot%s" % [robot_no]).turn_left(speed)

func robot_turn_right(robot_no):
	get_node("Bases/Robots/Robot%s" % [robot_no]).turn_right(speed)

func robot_pick_item(robot_no, pos):
	var rbt = $Bases/Robots.get_node("Robot%s" % [robot_no])
	var item = _find_item(pos)
	assert(item != null)
	$Bases/Entities.remove_child(item)

	rbt.item = item
	rbt.pick_up(speed)

func robot_pick_source(robot_no, item_holding):
	var rbt = $Bases/Robots.get_node("Robot%s" % [robot_no])
	rbt.item = _instance_entity([0, 0], item_holding)
	rbt.pick_up(speed)

func robot_put_item(robot_no, pos, item_holding, item_target):
	var rbt = $Bases/Robots.get_node("Robot%s" % [robot_no])
	rbt.put_down(speed)
	yield(rbt, "action_completed")

	var node = rbt.pop_item()
	node.queue_free()
	_clear_item_at(pos)
	
	if item_holding != null:
		rbt.item = _instance_entity([0, 0], item_holding)
	
	if item_target != null:
		$Bases/Entities.add_child(_instance_entity(pos, item_target))

func robot_drain_item(robot_no, item_holding):
	var rbt = $Bases/Robots.get_node("Robot%s" % [robot_no])
	rbt.put_down(speed)
	yield(rbt, "action_completed")
	
	var node = rbt.pop_item()
	node.queue_free()

	if item_holding != null:
		rbt.item = _instance_entity([0, 0], item_holding)

func robot_deliver_item(robot_no):
	var rbt = $Bases/Robots.get_node("Robot%s" % [robot_no])
	rbt.put_down(speed)
	yield(rbt, "action_completed")
	var node = rbt.pop_item()
	node.queue_free()

func robot_chop_item(robot_no, pos, item):
	var rbt = $Bases/Robots.get_node("Robot%s" % [robot_no])
	rbt.chop(speed)
	yield(rbt, "action_completed")
	_clear_item_at(pos)
	$Bases/Entities.add_child(_instance_entity(pos, item))

func robot_update_counter(robot_no, new_count):
	var rbt = $Bases/Robots.get_node("Robot%s" % [robot_no])
	rbt.get_item().count = new_count
	rbt.change_counter(speed)

func robot_show_error(robot_no, errmsg):
	var rbt = $Bases/Robots.get_node("Robot%s" % [robot_no])
	var popup = TextPopup.instance()
	popup.translation = rbt.translation
	popup.translation.y = 2.4
	popup.initialize(speed, errmsg)
	$Bases/Popups.add_child(popup)

# Private methods

func _instance_entity(pos, params):
	match params.type:
		"item":
			return _instance_item(pos, params)
		
		"container":
			return _instance_container(pos, params)
		
		"counter":
			return _instance_counter(pos, params)
		
		_:
			assert(false)

func _instance_item(pos, params):
	var it = Item.instance()
	
	it.translation = Vector3(pos[0], 0.667, pos[1])
	it.pos = pos
	it.type = params.name
	it.stage = params.stage
	print("stage.gd: instanced a %s:%s on %s" % [it.type, it.stage, it.pos])
	return it

func _instance_container(pos, params):
	var ct = Container.instance()
	ct.translation = Vector3(pos[0], 0.667, pos[1])
	ct.pos = pos
	ct.type = params.name
	if params.holding != null:
		ct.item = _instance_item([0, 0], params.holding)
	return ct

func _instance_counter(pos, params):
	var ct = Counter.instance()
	ct.translation = Vector3(pos[0], 0.667, pos[1])
	ct.pos = pos
	ct.count = params.count
	return ct

func _find_item(pos):
	for ent in $Bases/Entities.get_children():
		# Note: the array cannot be match using an equal operator
		# because the items of pos is float (not integer)
		if pos[0] == ent.pos[0] and pos[1] == ent.pos[1]:
			return ent
	return null

func _clear_item_at(pos):
	var entity = _find_item(pos)
	if entity != null:
		$Bases/Entities.remove_child(entity)
		entity.queue_free()

func _reset_map():
	# Delete all of the tiles and entities
	var tiles = $Bases/Tiles
	$Bases.remove_child(tiles)
	tiles.queue_free()

	var robots = $Bases/Robots
	$Bases.remove_child(robots)
	robots.queue_free()
	
	var entities = $Bases/Entities
	$Bases.remove_child(entities)
	entities.queue_free()
	
	var popups = $Bases/Popups
	$Bases.remove_child(popups)
	popups.queue_free()
	
	# Add these nodes back
	var new_tiles = Spatial.new()
	new_tiles.name = "Tiles"
	$Bases.add_child(new_tiles)
	
	var new_robots = Spatial.new()
	new_robots.name = "Robots"
	$Bases.add_child(new_robots)
	
	var new_entities = Spatial.new()
	new_entities.name = "Entities"
	$Bases.add_child(new_entities)
	
	var new_popups = Spatial.new()
	new_popups.name = "Popups"
	$Bases.add_child(new_popups)

func _ready():
	pass

var is_panning = false
	
func _unhandled_input(event):
	var delta = 2
	
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		is_panning = event.pressed
		
	if event is InputEventMouseMotion:
		if is_panning:
			var x_diff = -event.relative.x
			$CameraPod.rotate_y(x_diff / 200)

	if event is InputEventMouseButton and event.pressed:
		var z = $CameraPod/Extender/Camera.translation.z
		
		match event.button_index:
			BUTTON_WHEEL_UP:
				z = clamp(z + delta, 10, 30)
			
			BUTTON_WHEEL_DOWN:
				z = clamp(z - delta, 10, 30)
		
		$CameraPod/Extender/Camera.translation.z = z