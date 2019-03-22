extends HBoxContainer

var operators = [
	"==",
	"!=",
	">",
	"<",
	">=",
	"<="
]

func _ready():
	for op in operators:
		$Operator.add_item(op)
