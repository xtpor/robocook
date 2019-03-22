extends HBoxContainer


var Entry = preload("./entry.tscn")

func _ready():
	add_entry()

func add_entry():
	var entry = Entry.instance()
	$Item.add_child(entry)
	entry.connect("add", self, "add_entry")
	entry.connect("remove", self, "remove_entry", [entry])
	reflow()

func remove_entry(node):
	$Item.remove_child(node)
	reflow()

func reflow():
	for c in $Item.get_children():
		c.reflow()