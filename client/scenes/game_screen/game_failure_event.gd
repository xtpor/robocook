extends PanelContainer


var Entry = preload("./game_failure_entry.tscn")

var to_be_deleted = false

func init(e):
	print("game_failure_event.gd: %s" % [e])
	
	_set_entry($Margin/Content/Primary, e.goal.primary, e.status.primary)
	if e.goal.secondaries.size() > 0:
		for i in range(e.goal.secondaries.size()):
			var entry = Entry.instance()
			_set_entry(entry, e.goal.secondaries[i], e.status.secondaries[i])
			$Margin/Content.add_child(entry)
	else:
		$Margin/Content/TitleSecondary.visible = false
	
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

func _set_entry(entry, text, status):
	entry.get_node("Message").text = text
	entry.get_node("IconCross").visible = status != "complete"
	entry.get_node("IconTick").visible = status == "complete"