extends "code_block.gd"

func set_counter(n):
	$MarginContainer/HBoxContainer/SpinBox.value = n

func get_counter():
	return $MarginContainer/HBoxContainer/SpinBox.value