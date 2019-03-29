extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_SerializeButton_pressed():
	var output = $BlockEditor.serialize()
	$Code.text = JSON.print(output)

func _on_DeserializeButton_pressed():
	var r = JSON.parse($Code.text)
	var ast = r.result
	$BlockEditor.deserialize(ast)

func _on_ClearButton_pressed():
	$BlockEditor.clear()


func _on_EnableButton_pressed():
	$BlockEditor.set_readonly(false)
	$BlockDock.set_readonly(false)

func _on_DisableButton_pressed():
	$BlockEditor.set_readonly(true)
	$BlockDock.set_readonly(true)


func _on_DisableButton2_pressed():
	var seconds = 5
	var s = seconds
	
	$DisableButton2.disabled = true
	while s > 0:
		s -= 1
		$DisableButton2.text = "disable in %s" % [s]
		yield(get_tree().create_timer(1), "timeout")

	$DisableButton2.disabled = false
	$DisableButton2.text = "disable in %s" % [seconds]
	_on_DisableButton_pressed()
