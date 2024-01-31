extends LineEdit


func _on_text_submitted(new_text):
	release_focus()
	if new_text.is_valid_float():
		Globals.scale_modifier = float(new_text)
	else:
		text = str(Globals.scale_modifier)
