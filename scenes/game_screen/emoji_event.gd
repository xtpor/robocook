extends PanelContainer

const resources = {
	"grinning": preload("res://images/emojis/grinning.png"),
	"rolling": preload("res://images/emojis/rolling.png"),
	"squinting": preload("res://images/emojis/squinting.png"),
	"stuck_out_tongue": preload("res://images/emojis/stuck_out_tongue.png"),
	"thinking": preload("res://images/emojis/thinking.png"),
	
	"kissing": preload("res://images/emojis/kissing.png"),
	"fearful": preload("res://images/emojis/fearful.png"),
	"pensive": preload("res://images/emojis/pensive.png"),
	"frowning": preload("res://images/emojis/frowning.png"),
	"thumbs_up": preload("res://images/emojis/thumbs_up.png"),
}


var to_be_deleted = false

func init(e):
	$Margin/Content/Top/PlayerName.text = e.player
	$Margin/Content/Emoji.texture = resources[e.emoji]

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