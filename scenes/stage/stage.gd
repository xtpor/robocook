extends Spatial

var json = """
{"size":[2,2],"data":[{"tile":{"variation":0,"type":"stove","extra":null},"entity":null},{"tile":{"variation":0,"type":"table","extra":null},"entity":null},{"tile":{"variation":0,"type":"table","extra":null},"entity":{"type":"robot","no":0,"holding":{"type":"item","stage":0,"name":"raw_steak"},"dir":[1,0]}},{"tile":{"variation":1,"type":"table","extra":null},"entity":{"type":"container","name":"pan","holding":null}}]}
"""

var map = JSON.parse(json).result


var Robot = preload("./robot/robot.tscn")

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

var zoom_mapping = {
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

func build_scene(map):
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
		
		if entry.entity != null and entry.entity.type == "robot":
			var rbt = Robot.instance()
			$Bases/Tiles.add_child(rbt)
			rbt.init(entry.entity)
			rbt.translation.x = i
			rbt.translation.z = j
	
	var size = int(max(width, height))
	$Bases.translation.x = -((width - 1) / 2.0)
	$Bases.translation.z = -((height - 1) / 2.0)
	$CameraPod/Extender/Camera.translation.z = zoom_mapping[size]

func _ready():
	# screen_test()
	# _build_scene()
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
	
func screen_test():
	var width = 1
	var height = 1
	
	$ShowFov.text = "z = %s" % [$CameraPod/Extender/Camera.translation.z]

	for i in range(1, 15 + 1):
		yield($Button, "pressed")
		print("scene size = %s, %s" % [width, height])
		
		width += 1
		height += 1
		
		# $CameraPod/Camera.fov = 30 + i * 2
		# $ShowFov.text = "fov = %s" % [$CameraPod/Camera.fov]
		var z = $CameraPod/Extender/Camera.translation.z
		var new_z = zoom_mapping[width]
		$Tween.interpolate_property($CameraPod/Extender/Camera, @"translation:z", z, new_z, 1, Tween.TRANS_SINE, Tween.EASE_OUT)
		$Tween.start()
		
		var obj = tile_mapping["floor"].instance()
		$Bases/Tiles.add_child(obj)
		obj.translation.x = i
		obj.translation.z = 0
		
		var obj2 = tile_mapping["floor"].instance()
		$Bases/Tiles.add_child(obj2)
		obj2.translation.x = 0
		obj2.translation.z = i
		
		$Bases.translation.x = -((width - 1) / 2.0)
		$Bases.translation.z = -((height - 1) / 2.0)