extends "code_block.gd"

func serialize_condition():
	return $MarginContainer/HBoxContainer/Condition.serialize_condition()

func deserialize_condition(condition):
	$MarginContainer/HBoxContainer/Condition.deserialize_condition(condition)