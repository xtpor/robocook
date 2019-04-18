extends VBoxContainer


const MAX_EVENT = 5

var ChatEvent = preload("./chat_event.tscn")
var EmojiEvent = preload("./emoji_event.tscn")
var GameFailureEvent = preload("./game_failure_event.tscn")

func add_chat_event(e):
	var obj = ChatEvent.instance()
	obj.init(e)
	add_child(obj)

func add_emoji_event(e):
	var obj = EmojiEvent.instance()
	obj.init(e)
	add_child(obj)

func add_game_failure_event(e):
	var obj = GameFailureEvent.instance()
	obj.init(e)
	add_child(obj)

func _process(_delta):
	if get_child_count() > 0:
		var first_child = get_child(0)
		if first_child.to_be_deleted:
			first_child.delete()
	
	if get_child_count() > MAX_EVENT:
		get_child(0).delete()