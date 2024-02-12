extends Button

func _on_terrain_test_hide_origin(o_hidden):
	if o_hidden == false:
		text = "Show Origin"
	else:
		text = "Hide Origin"
