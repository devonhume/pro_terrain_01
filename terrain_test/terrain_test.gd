extends Node3D

signal player_position(position)
signal flying(is_flying)
signal hide_ui(hidden)
signal hide_origin(o_hidden)
signal hide_markers(m_hidden)

@onready var player = get_node("Player")
@onready var terrain = get_node("terrain")
@onready var origin = get_node("OriginMarker")
@onready var pointer = preload("res://terrain_test/pointer.tscn")
@onready var marker_button = preload("res://gui/MarkerButton.tscn")

@export var flying_mode = false
@export var ray_distance = 2000

var ui_hidden = false
var origin_marker_hidden = false
var markers_hidden = false
var space_state
var button_tracker = 1

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
			
func _physics_process(delta):
	space_state = get_world_3d().direct_space_state
	
			
func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var click_location = screen_point_to_ray()
			if click_location:
				add_marker(click_location)
			
func screen_point_to_ray():
	
	var mouse_position = get_viewport().get_mouse_position()
	var camera = $Player/Camera3D
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_position) * ray_distance
	var ray_query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var ray_array = space_state.intersect_ray(ray_query) # fires the ray
	if ray_array.has("position"):
		return ray_array
	return null
	
func add_marker(click):
	var new_marker = pointer.instantiate()
	var marker_name = str("Pointer", button_tracker)
	new_marker.name = marker_name
	new_marker.click_body = click
	new_marker.position = click["position"]
	add_child(new_marker)
	var button = marker_button.instantiate()
	var button_name = str("Marker", button_tracker)
	button.set_name(button_name)
	button.text = str("Marker ", button_tracker)
	button.location = click["position"]
	var grid = get_node("TerrainCanvasLayer/LeftMarginContainer/LeftGridContainer/MarkerGridContainer")
	grid.add_child(button)
	button_tracker += 1
	button.marker_button_pressed.connect(_on_marker_button_pressed)
	
	

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
	


func _on_hide_markers_button_pressed():
	if button_tracker > 1:
		var marker_grid = get_node("TerrainCanvasLayer/LeftMarginContainer/LeftGridContainer/MarkerGridContainer")
		var pointers = []
		for i in range(0, button_tracker - 1):
			var pointer_name = str("Pointer", i + 1)
			pointers.append(get_node(pointer_name))
		if markers_hidden == false:
			marker_grid.visible = false
			for pointer in pointers:
				pointer.visible = false
			markers_hidden = true
		else:
			marker_grid.visible = true
			for pointer in pointers:
				pointer.visible = true
			markers_hidden = false


func _on_hide_origin_button_pressed():
	if origin.visible == true:
		origin.visible = false
		hide_origin.emit(false)
	else:
		origin.visible = true
		hide_origin.emit(true)

func _on_marker_button_pressed(location):
	player.position = location
