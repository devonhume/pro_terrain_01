extends Button


func _on_terrain_test_hide_markers(m_hidden):
	if m_hidden == false:
		text = "Show Markers"
	else:
		text = "Hide Markers"
