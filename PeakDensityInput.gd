extends SpinBox

@onready var line = get_line_edit()

func _ready():
	value = Globals.peak_density

func _on_value_changed(value):
	
	Globals.peak_density = value
	line.release_focus()
