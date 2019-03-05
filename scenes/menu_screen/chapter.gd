extends VBoxContainer

signal level_selected(level)

var Level = preload("./level.tscn")

func init(chapter):
	$Name.text = chapter.name
	
	for i in range(chapter.levels.size()):
		var level = chapter.levels[i]
		
		var obj = Level.instance()
		obj.init(i, level)
		obj.connect("level_selected", self, "_on_level_selected")
		$Levels.add_child(obj)

func _on_level_selected(level):
	emit_signal("level_selected", level)