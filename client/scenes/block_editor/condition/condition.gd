extends HBoxContainer


var Entry = preload("./entry.tscn")

func _ready():
	if $Item.get_child_count() == 0:
		add_entry()

func add_entry():
	var entry = Entry.instance()
	$Item.add_child(entry)
	entry.connect("add", self, "add_entry")
	entry.connect("remove", self, "remove_entry", [entry])
	reflow()
	return entry

func remove_entry(node):
	$Item.remove_child(node)
	reflow()

func reflow():
	for c in $Item.get_children():
		c.reflow()

func serialize_condition():
	return serialize_loop(0)

func serialize_loop(i):
	var item = $Item.get_child(i)
	if i == $Item.get_child_count() - 1:
		return item.serialize_condition()
	else:
		return [item.serialize_operator(), item.serialize_condition(), serialize_loop(i + 1)]

func deserialize_condition(cond):
	deserialize_loop(cond)
	reflow()

func deserialize_loop(cond):
	match cond:
		[var op, var cond1, var cond2]:
			var e = add_entry()
			e.deserialize_operator(op)
			e.deserialize_condition(cond1)
			deserialize_loop(cond2)
		var cond1:
			var e = add_entry()
			e.deserialize_condition(cond1)
	reflow()