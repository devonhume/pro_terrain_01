extends Node3D

signal player_position(position)

@onready var player = get_node("Player")
@onready var terrain = get_node("terrain")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if Input.is_action_just_pressed("print"):
		print("player position: ", player.position)
		
	if Input.is_action_just_pressed("chunks"):
		terrain.print_chunks()

func _on_terrain_terrain_made():
	
	#print_tree()
	print("+-----------------------------------------------------------+")


func _on_terrain_check_position():
	
	player_position.emit(player.position)
