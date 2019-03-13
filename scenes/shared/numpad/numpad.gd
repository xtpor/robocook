extends GridContainer

signal numpad_completed(numbers)

export (bool) var readonly = false
var pads

var numbers setget _set_numbers, _get_numbers

func _ready():
	pads = [
		$Button1, $Button2, $Button3, $Button4,
		$Button5, $Button6, $Button7, $Button8,
		$Button9, $Button10, $Button11, $Button12,
		$Button13, $Button14, $Button15, $Button16,
	]
	
	for i in range(pads.size()):
		pads[i].connect("pressed", self, "_on_pad_pressed", [i])

func _on_pad_pressed(i):
	if readonly:
		return
	
	if pads[i].text == "o":
		pads[i].text = ""
	else:
		var n = self.numbers.size()
		if n >= 4:
			pass
		else:
			pads[i].text = "o"
			if n == 3:
				emit_signal("numpad_completed", self.numbers)

func _count_completed():
	var count = 0
	for pad in pads:
		if pad.text == "o":
			count += 1
	return count

func _set_numbers(values):
	for pad in pads:
		pad.text = ""
	for v in values:
		pads[v].text = "o"

func _get_numbers():
	var result = []
	for i in range(pads.size()):
		if pads[i].text == "o":
			result.append(i)
	
	return result