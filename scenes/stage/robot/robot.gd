extends Spatial


var models

func _ready():
	models = [$robot_0, $robot_1, $robot_2, $robot_3]

func init(data):
	set_direction(data.dir)
	set_no(data.no)

func set_no(no):
	for m in models:
		m.visible = false
	models[no].visible = true

func set_direction(dir):
	match dir:
		[0.0, 1.0]:
			rotation_degrees = Vector3(0, 0, 0)
		[1.0, 0.0]:
			rotation_degrees = Vector3(0, 90, 0)
		[0.0, -1.0]:
			rotation_degrees = Vector3(0, 180, 0)
		[-1.0, 0.0]:
			rotation_degrees = Vector3(0, 270, 0)
		_:
			assert(false)