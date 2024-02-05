extends Button



func _on_terrain_test_flying(is_flying):
	
	if is_flying:
		text = "Flying"
		
	else:
		text = "Fly"
