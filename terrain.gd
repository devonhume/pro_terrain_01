extends StaticBody3D

var TerrainMap = load("res://terrain_map.gd")

@onready var hex_array = get_node("Hex_Array")
@onready var player = get_node("Player")

var gems_mat = preload("res://assets/materials/gems.tres")
var gray_mat = preload("res://assets/materials/gray.tres")
var blue_mat = preload("res://assets/materials/blue.tres")

@export var mesh_size = 4
@export var scale_modifier = 1.0
@export var chunk_distance = 100
@export var peak_density = 2
@export var peak_modifier = 4.0

var x_offset = (mesh_size * 3 * scale_modifier)
var z_offset = make_z_offset(mesh_size, scale_modifier)

var terrain_map

var player_position = null

var isready = false
var checking = false
var making = false

signal terrain_made
signal check_position

func _ready():
	
	pass 

func _on_hex_array_ready():
	
	pass

func _on_hex_array_shape_signal(arr_mesh, offset, edges):
	
	var col_shape
	
	var stat_name = str("Hex_Stat", terrain_map.tracker)
	var child_stat = StaticBody3D.new()
	child_stat.set_name(stat_name)
	
	var mesh_name = str("Hex_Mesh", terrain_map.tracker)
	var child_mesh = MeshInstance3D.new()
	child_mesh.set_name(mesh_name)
	# child_mesh.position = offset
	child_stat.add_child(child_mesh)
	child_mesh.mesh = arr_mesh
	col_shape = child_mesh.mesh.create_trimesh_shape()
		
	var child_col = CollisionShape3D.new()
	child_col.shape = col_shape
	child_stat.add_child(child_col)
	
	child_stat.position = offset
	add_child(child_stat)
	arr_mesh.regen_normal_maps()
	
	if terrain_map.tracker == 0:
		var platform = get_node("Platform")
		platform.disabled = true
	terrain_map.tracker += 1
	terrain_map.activate_chunk(child_stat.position, stat_name, edges)
	
	making = false
	
	terrain_made.emit()

func _on_terrain_test_player_position(plyer_position):
		
	player_position = plyer_position
	
	if not checking and not making:
		
		checking = true
		
		if not isready:
			x_offset = (mesh_size * 3 * scale_modifier)
			z_offset = make_z_offset(mesh_size, scale_modifier)
			
			print("x_offset: ", x_offset, ", z_offset: ", z_offset, ", mesh_size: ", mesh_size, " hex_array.size: ", hex_array.size)
			
			terrain_map = TerrainMap.new(x_offset, z_offset, mesh_size)
			
			isready = true
	
		var all_chunks = terrain_map.get_all_chunks()
		
		for chunk in range(0, len(all_chunks)):
			
			var distance = player_position.distance_to(all_chunks[chunk][0])
			
			if distance < chunk_distance and not terrain_map.get_status(all_chunks[chunk][1]):
				
				making = true
				
				var edges = terrain_map.get_edges(all_chunks[chunk][1])
				
				hex_array.current_chunk = all_chunks[chunk][1]
				hex_array.size = mesh_size
				hex_array.build_scale = scale_modifier
				hex_array.position = all_chunks[chunk][0]
				hex_array.make_mesh(all_chunks[chunk], edges, peak_density, peak_modifier, terrain_map)
				
		checking = false
		
func make_z_offset(size, mesh_scale):
	
	var z_mod = int(size * 0.66)
	var Z_INC = snapped(1.73 * mesh_scale, 0.001)
	
	return snapped(Z_INC * (size + z_mod), 0.001)

func _on_timer_timeout():
	
	check_position.emit()
	

