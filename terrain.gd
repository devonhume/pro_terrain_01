extends StaticBody3D

var TerrainMap = load("res://terrain_map.gd")

# @onready var col_node_shape = get_node("CollisionShape3D")
@onready var hex_array = get_node("Hex_Array")

var gems_mat = preload("res://assets/materials/gems.tres")

@export var mesh_size = 4
@export var scale_modifier = 1.0
@export var chunk_distance = 100
@export var peak_density = 2
@export var peak_modifier = 4.0

var x_offset = (mesh_size * 3 * scale_modifier)
var z_offset = make_z_offset(mesh_size, scale_modifier)

var terrain_map

var isready = false
var checking = false
var making = false

signal terrain_made
signal check_position

# var terrain_chunks = []
# var terrain_status = []
# var terrain_tracker = 0

# var coll_shape

func _ready():
	
	pass 
	# print("x_offset: ", x_offset, ", z_offset: ", z_offset)
	# terrain_chunks.append(Vector3(0, 0, 0))
	# terrain_status.append(false)
	# print("coll_shape: ", coll_shape)
	# col_node_shape.shape = stand_verts
	

func _on_hex_array_ready():
	
	pass

func _on_hex_array_shape_signal(arr_mesh, offset, edges):
	
	var col_shape
	# coll_shape = col_shape
	# print("on_signal offset: ", offset)
	
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
		
	# var child_name = str("Terrain_Coll", terrain_map.tracker)
	var child_col = CollisionShape3D.new()
	# achild_col.position = offset
	# child_col.set_name(child_name)
	child_col.shape = col_shape
	child_stat.add_child(child_col)
	
	child_stat.position = offset
	add_child(child_stat)
	arr_mesh.regen_normal_maps()
	
	# print("added ", child_name, ", position: ", child_col.position)
	
	if terrain_map.tracker == 0:
		var platform = get_node("Platform")
		platform.disabled = true
	terrain_map.tracker += 1
	terrain_map.activate_chunk(child_stat.position, stat_name, edges)
	
	making = false
	
	# var edge_report_original_top = terrain_map.terrain_map[0][0].edges[0]
	# var edge_report_added_bottom = null
	
	#if terrain_map.terrain_map[1][2].status:
	#	edge_report_added_bottom = terrain_map.terrain_map[1][2].edges[1]
		
	# print("original top: ", edge_report_original_top)
	# print("added bottom: ", edge_report_added_bottom)
	# print("terrain map: ", terrain_map.terrain_map)
	# print("stat position: ", child_stat.position)
	# print("coll position: ", child_col.position)
	
	# var mesh_vertices = []
	
	# var mdt = MeshDataTool.new() 
	# var m = child_mesh.get_mesh()
	#get surface 0 into mesh data tool
	# mdt.create_from_surface(m, 0)
	# for vtx in range(mdt.get_vertex_count()):
	# 	var vert = mdt.get_vertex(vtx)
	# 	mesh_vertices.append(vert)
		
	# print("global vertices: ", mesh_vertices)
	
	terrain_made.emit()
	
	# for i in range(0, terrain_map.tracker):
	#	var node_name = str("Hex_Stat", i)
	#	var mesh_node = get_node(node_name)
	#	print(node_name, ".position: ", mesh_node.position)

func _on_terrain_test_player_position(player_position):
	
	if not checking and not making:
		
		checking = true
		
		if not isready:
			#hex_array.size = mesh_size
			x_offset = (mesh_size * 3 * scale_modifier)
			z_offset = make_z_offset(mesh_size, scale_modifier)
			
			print("x_offset: ", x_offset, ", z_offset: ", z_offset, ", mesh_size: ", mesh_size, " hex_array.size: ", hex_array.size)
			
			terrain_map = TerrainMap.new(x_offset, z_offset, mesh_size)
			# hex_array.size = mesh_size
			
			isready = true
	
		var all_chunks = terrain_map.get_all_chunks()
		# print(all_chunks)
		
		for chunk in range(0, len(all_chunks)):
			
			var distance = player_position.distance_to(all_chunks[chunk][0])
			
			#if distance < mesh_size * 2.5 and not terrain_map.get_status(all_chunks[chunk][1]):
			if distance < chunk_distance and not terrain_map.get_status(all_chunks[chunk][1]):
				
				print("player distance activate: ", all_chunks[chunk])
				print("player_position: ", player_position)
				
				making = true
				
				var edges = terrain_map.get_edges(all_chunks[chunk][1])
				
				# print("edges: ", edges)
				# if edges[3]:
					# print(terrain_map.terrain_map[0][0].edges[3])
				
				if all_chunks[chunk][1][0] == 2 :
					if all_chunks[chunk][1][1] == 15 or all_chunks[chunk][1][1] < 2:
						print("---+ chunk 2,", all_chunks[chunk][1][1], " edges: ", edges)
				
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

func print_chunks():
	
	var spec_chunk = get_node("Hex_Stat9/Hex_Mesh9")
	
	spec_chunk.set_surface_override_material(0, gems_mat)
	
	# print(spec_chunk)
	
	# print_tree()
	
	terrain_map.print_chunks()
