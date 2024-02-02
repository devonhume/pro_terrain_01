extends Node3D

signal player_position(position)
signal flying(is_flying)
signal hide_ui(hidden)

@onready var player = get_node("Player")
@onready var terrain = get_node("terrain")

@export var flying_mode = false

var ui_hidden = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if Input.is_action_just_pressed("fly"):
		if flying_mode:
			flying_mode = false
			print("FLYING OFF")
			flying.emit(false)
		else:
			flying_mode = true
			print("FLYING ON")
			flying.emit(true)
			
		player.flying_mode = flying_mode
		terrain.flying_mode = flying_mode
		
	if Input.is_action_just_pressed("hide"):
		
		if ui_hidden:
			hide_ui.emit(false)
			ui_hidden = false
		else:
			hide_ui.emit(true)
			ui_hidden = true
			

func _on_terrain_terrain_made():
	
	pass

func _on_terrain_check_position():
	
	player_position.emit(player.position)


func _on_flying_button_pressed():
	
	if flying_mode:
		flying_mode = false
		print("FLYING BUTTON OFF")
		flying.emit(false)
	else:
		flying_mode = true
		print("FLYING BUTTON ON")
		flying.emit(true)
			
	player.flying_mode = flying_mode
	terrain.flying_mode = flying_mode


func _on_reset_button_pressed():
	if not flying_mode:
		flying_mode = true
		flying.emit(true)
		player.flying_mode = flying_mode
		terrain.flying_mode = flying_mode		
	if player.position.y < 10:
		player.position.y = 10
	terrain.reset()



func _on_origin_button_pressed():
	
	var player_y = player.position.y
	if player_y < 10:
		player_y = 10
		
	player.position = Vector3(0, player_y, 0)
	
