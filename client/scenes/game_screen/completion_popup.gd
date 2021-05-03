extends Control


signal menu_pressed()

var Entry = preload("res://scenes/game_screen/completion_popup_entry.tscn")

func _process(delta):
	$Pivot.position = rect_size * 0.5

func initialize(goals, statuses):
	# Set the primary goal
	_set_entry($Pivot/Center/Panel/Margin/Items/Primary/Entry, goals.primary, statuses.primary)
	
	# Set the secondary goal
	var num_secondaries = goals.secondaries.size()
	if num_secondaries > 0:
		for i in range(num_secondaries):
			var entry = Entry.instance()
			_set_entry(entry, goals.secondaries[i], statuses.secondaries[i])
			$Pivot/Center/Panel/Margin/Items/Secondary.add_child(entry)
	else:
		$Pivot/Center/Panel/Margin/Items/Secondary.visible = false
	
	visible = true
	$Pivot.scale = Vector2(0, 0)
	$Tween.interpolate_property($Pivot, "scale", Vector2(0, 0), Vector2(1, 1), 0.25, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()

func _set_entry(entry, text, status):
	entry.get_node("Message").text = text
	entry.get_node("IconCross").visible = status != "complete"
	entry.get_node("IconTick").visible = status == "complete"

func _on_menu_button_pressed():
	emit_signal("menu_pressed")
