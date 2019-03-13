extends PanelContainer

var ObjectiveLabel = preload("./objective_label.tscn")


func set_title(title):
	$Margin/Items/TitleLabel.text = title

func set_description(desc):
	$Margin/Items/DescriptionLabel.text = desc

func set_goal(goal):
	$Margin/Items/PrimaryObjectiveLabel.text = goal.primary
	
	var s = goal.secondaries.size()
	if s > 0:
		for i in range(s):
			var label = ObjectiveLabel.instance()
			label.text = "%s. %s" % [i + 1, goal.secondaries[i]]
			$Margin/Items.add_child(label)
			
	else:
		var label = ObjectiveLabel.instance()
		label.text = "N/A"
		$Margin/Items.add_child(label)