extends Control


signal level_selected(level)

var my_level

func init(i, level):
	my_level = level
	$Button.text = str(i + 1)
	
	if level.multiplayer:
		$Multiplayer.visible = true

func _on_button_pressed():
	emit_signal("level_selected", my_level)
