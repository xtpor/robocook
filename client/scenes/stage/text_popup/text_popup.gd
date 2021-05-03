extends Spatial


func _ready():
	var mat = $Board.get_surface_material(0)
	mat.albedo_texture = $Board/Viewport.get_texture()

func initialize(speed, text):
	var duration = 1.0 / speed
	print("duration = %s" % [duration])
	$Board/Viewport/TextMessage/Panel/Margin/Label.text = text
	scale = Vector3(0, 0, 0)
	$Tween.interpolate_property(self, "scale", Vector3(0, 0, 0), Vector3(1, 1, 1), 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	scale = Vector3(1, 1, 1)
	yield(get_tree().create_timer(duration - 0.1), "timeout")
	queue_free()