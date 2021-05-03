extends PanelContainer


var to_be_deleted = false

func init(e):
	$Margin/Content/Top/PlayerName.text = e.player
	$Margin/Content/Message.text = e.text
	
	modulate.a = 0
	$Tween.interpolate_property(self, @"modulate:a", 0.0, 1.0, 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()

var deleting = false

func delete():
	if deleting:
		return
	deleting = true
	
	$Tween.stop_all()
	$Tween.interpolate_property(self, @"modulate:a", 1.0, 0.0, 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	
	$"..".remove_child(self)
	queue_free()

func _on_timeout():
	to_be_deleted = true
