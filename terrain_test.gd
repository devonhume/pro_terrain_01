extends Node3D

signal player_position(position)

@onready var player = get_node("Player")
@onready var terrain = get_node("terrain")

@export var flying_mode = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if Input.is_action_just_pressed("fly"):
		if flying_mode:
			flying_mode = false
			print("FLYING OFF")
		else:
			flying_mode = true
			print("FLYING ON")
			
		player.flying_mode = flying_mode
		terrain.flying_mode = flying_mode

func _on_terrain_terrain_made():
	
	pass

func _on_terrain_check_position():
	
	player_position.emit(player.position)


func _on_flying_button_pressed():
	
	if flying_mode:
		flying_mode = false
		print("FLYING BUTTON OFF")
	else:
		flying_mode = true
		print("FLYING BUTTON ON")
			
	player.flying_mode = flying_mode
	terrain.flying_mode = flying_mode


func _on_reset_button_pressed():
	if not flying_mode:
		flying_mode = true
		player.flying_mode = flying_mode
		terrain.flying_mode = flying_mode		
	if player.position.y < 10:
		player.position.y = 10
	terrain.reset()

