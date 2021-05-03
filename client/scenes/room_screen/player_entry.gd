extends HBoxContainer

signal kick_player(name)


var _no
var _name
var _enable_kick

func init(player_no, player_name, enable_kick):
	_no = player_no
	_name = player_name
	_enable_kick = enable_kick
	
	$PlayerLabel.text = "Player %s" % [player_no + 1]
	update_name(_name)

func update_name(name):
	_name = name
	
	$PlayerName.text = "-" if _name == null else _name
	$KickButton.visible = false if _no == 0 or _name == null else _enable_kick

func _on_kick_button_pressed():
	emit_signal("kick_player", _name)
