extends Spatial


var Robot = preload("./robot.tscn")
var Counter = preload("./counter/counter.tscn")

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
		
		var obj = tile_mapping[entry.tile.type].instance()
		$Bases/Tiles.add_child(obj)
		obj.translation.x = i
		obj.translation.z = j
		
		if entry.entity != null:
			var entity = entry.entity
			
			match entity:
				{"type": "robot", ..}:
					var rbt = Robot.instance()
					$Bases/Robots.add_child(rbt)
		
					var no = entry.entity.no
					rbt.name = "Robot%s" % [no]
					rbt.robot_no = no
					rbt.player_no = controls[rbt.robot_no]
					rbt.dir = entry.entity.dir
					rbt.translation.x = i
					rbt.translation.z = j
				
				{"type": "counter", ..}:
					var ct = Counter.instance()
					$Bases/Entities.add_child(ct)
					ct.translation.x = i
					ct.translation.z = j
					ct.translation.y = 0.667 # Level on the table
					ct.count = entity.count
				
				_:
					print("stage.gd: Unhandled entity creation %s" % [entity])
	
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
	$Bases/Entities.remove_child(item)

	rbt.set_item(item)
	rbt.pick_up(speed)

func robot_put_item(robot_no, pos, itemobj):
	match itemobj.type:
		"counter":
			var rbt = $Bases/Robots.get_node("Robot%s" % [robot_no])
			var item = rbt.pop_item()
			$Bases/Entities.add_child(item)
			item.translation.x = pos[0]
			item.translation.z = pos[1]
			item.translation.y = 0.667
			rbt.put_down(speed)
		_:
			assert(false)

func robot_update_counter(robot_no, new_count):
	var rbt = $Bases/Robots.get_node("Robot%s" % [robot_no])
	rbt.get_item().count = new_count
	rbt.change_counter(speed)

# Private methods

func _find_item(pos):
	for ent in $Bases/Entities.get_children():
		if ent.pos[0] == pos[0] and ent.pos[1] == pos[1]:
			return ent
	assert(false)

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
				print("wheel up")
			
			BUTTON_WHEEL_DOWN:
				z = clamp(z - delta, 10, 30)
				print("wheel down")
		
		print("z = %s" % [z])
		$CameraPod/Extender/Camera.translation.z = z