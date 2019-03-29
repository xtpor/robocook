extends HBoxContainer

var operators = [
	{"display": "==", "name": "eq"},
	{"display": "!=", "name": "ne"},
	{"display": ">", "name": "gt"},
	{"display": "<", "name": "lt"},
	{"display": ">=", "name": "gte"},
	{"display": "<=", "name": "lte"},
]

var _options_added = false

func _ready():
	_add_options()	

func _add_options():
	if not _options_added:
		for op in operators:
			$Operator.add_item(op.display)
	_options_added = true

func serialize():
	var op = operators[$Operator.selected].name
	return ["test", ["check_counter", op, $Count.value]]

func deserialize(cond):
	_add_options()
	match cond:
		["test", ["check_counter", var op, var value]]:
			var index = -1
			for i in range(operators.size()):
				if op == operators[i].name:
					index = i
			$Operator.select(index)
			$Count.value = value