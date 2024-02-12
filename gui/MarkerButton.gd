extends Button

signal marker_button_pressed(button_name)

var location

func _on_pressed():
	var new_location = Vector3(location[0], location[1] + 1, location[2])
	marker_button_pressed.emit(new_location)
