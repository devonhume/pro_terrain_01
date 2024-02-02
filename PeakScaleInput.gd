extends SpinBox

@onready var line = get_line_edit()

func _ready():
	value = Globals.peak_scale

func _on_value_changed(value):
	
	Globals.peak_scale = value
	line.release_focus()
