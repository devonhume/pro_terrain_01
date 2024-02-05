extends LineEdit


func _ready():
	text = str(Globals.ridge_distance)

func _on_text_submitted(new_text):
	release_focus()
	if new_text.is_valid_float():
		Globals.ridge_distance = float(new_text)
	else:
		text = str(Globals.ridge_distance)
