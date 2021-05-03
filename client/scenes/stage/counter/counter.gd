extends Spatial

var pos = [0, 0]
var count setget set_count, get_count

var _count = 0

func set_count(c):
	_count = c
	$Count/Viewport/CounterText/Label.text = "%02d" % [_count]

func get_count():
	return _count

func _ready():
	var mat = $Count.get_surface_material(0).duplicate()
	$Count.set_surface_material(0, mat)
	mat.albedo_texture = $Count/Viewport.get_texture()