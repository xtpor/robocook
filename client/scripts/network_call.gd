
signal result(data)

var result

func call_returned(data):
	result = data
	emit_signal("result", data)