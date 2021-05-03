extends VBoxContainer

signal kick_player(name)

var PlayerEntry = preload("./player_entry.tscn")

var player_list
var entries
var is_owner

func init(player_list, capacity, is_owner):
	if player_list.size() < capacity:
		for _i in range(capacity - player_list.size()):
			player_list.append(null)
	
	self.player_list = player_list
	self.is_owner = is_owner
	
	entries = []
	for i in player_list.size():
		var obj = PlayerEntry.instance()
		obj.init(i, player_list[i], is_owner)
		obj.connect("kick_player", self, "_on_kick_player")
		add_child(obj)
		entries.append(obj)

func player_joined(player_name):
	var i = 0
	for index in range(player_list.size()):
		i = index
		if player_list[i] == null:
			break
	
	player_list[i] = player_name
	entries[i].update_name(player_name)

func player_left(player_name):
	player_list.erase(player_name)
	player_list.append(null)
	
	for i in range(player_list.size()):
		entries[i].update_name(player_list[i])
		
func is_full():
	for p in player_list:
		if p == null:
			return false
	return true

func _on_kick_player(player_name):
	emit_signal("kick_player", player_name)