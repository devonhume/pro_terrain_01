extends Node

var player_position = null
var pointers = null
var pointer_inc = 0

func teleport():
	
	if pointers:
		if pointer_inc >= len(pointers):
			
			pointer_inc = 0
		
		var return_position = pointers[pointer_inc].position
		
		pointer_inc += 1
		print("pointer index: ", pointer_inc, ", pointer position: ", return_position)
		return return_position
		
	else:
		return Vector3(0, 2, 0)
		
