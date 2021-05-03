extends Control


signal level_selected(level)

var my_level

func init(i, level):
	my_level = level
	$Button.text = str(i + 1)
	
	if level.multiplayer:
		$Multiplayer.visible = true
	
	if level.status != null:
		$StarIcon.visible = true
		$StarCount.visible = true
		$StarCount.text = str(star_count(level.status))

func star_count(status):
	if status.primary == "complete":
		var c = 1
		for s in status.secondaries:
			if s == "complete":
				c += 1
		return c
	else:
		return 0

func _on_button_pressed():
	emit_signal("level_selected", my_level)
