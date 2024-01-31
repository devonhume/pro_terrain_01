extends SpinBox

@onready var line = get_line_edit()

func _on_value_changed(value):
	Globals.chunk_distance = value
	line.release_focus()
