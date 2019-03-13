extends Control

var EditorProcedure = preload("./editor_procedure.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_new_procedure_pressed():
	var proc = EditorProcedure.instance()
	proc.connect("delete", self, "_on_delete_procedure", [proc])
	$Margin/Scroll/Items.add_child(proc)
	reflow()

func _on_delete_procedure(proc):
	$Margin/Scroll/Items.remove_child(proc)
	reflow()

func reflow():
	var i = 0
	for i in $Margin/Scroll/Items.get_child_count() - 1:
		var proc = $Margin/Scroll/Items.get_child(i + 1)
		if i == 0:
			proc.set_title("Main Procedure")
		else:
			proc.set_title("Procedure %s" % [i])