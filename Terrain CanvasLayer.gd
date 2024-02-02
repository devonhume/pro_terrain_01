extends CanvasLayer


func _on_terrain_test_hide_ui(hidden):
	if hidden:
		set_visible(false)
	else:
		set_visible(true)
