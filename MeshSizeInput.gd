extends SpinBox

@onready var line = get_line_edit()

func _ready():
	value = Globals.mesh_size

func _on_value_changed(value):
	Globals.mesh_size = value
	line.release_focus()
