extends Node
class_name ChunkMeshGenerator

@export var size:int = 4
@export var build_scale:float = 1.0
@export var height_variation:float = 0.4
@export var uv_multiplier:float = 4.0

@export var default_material:Material = preload("res://assets/materials/terrain_shader_material.tres")

var ground_mat = preload("res://assets/materials/forest_floor.tres")
var dirt_mat = preload("res://assets/materials/dirt.tres")
var terrain_mat = preload("res://assets/materials/terrain_shader_material.tres")

var vert_list = []

var col_shape

@onready var terrain_map = get_node("./TerrainGenerator/TerrainMap")

var current_chunk = null
var offset = null
var edges = null

signal shape_signal(arr_mesh, offset, edges)

func make_mesh(chunk):
	
	offset = terrain_map.chunk_list[chunk][0]	
	var arr_mesh = ArrayMesh.new()
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)
	var triangle_array = make_hex_grid(chunk)
	var verts = PackedVector3Array(triangle_array[0][0])
	var uvs = PackedVector2Array(triangle_array[0][1])
	var normals = PackedVector3Array(triangle_array[0][2])
	var indices = PackedInt32Array(triangle_array[0][3])
	
	# add data to arrys
	
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX]  = indices
	
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	
	arr_mesh.surface_set_material(0, default_material)
	
	shape_signal.emit(arr_mesh, offset, triangle_array[1])
	
func make_hex_grid(chunk):
	
	var map_position = terrain_map.chunk_list[chunk][1]
			
	var top = []
	var bottom = []
	var left = []
	var right = []
		
	var y_mod = int(size * 0.66)
	
	var Y_INC = snapped(1.73 * build_scale, 0.001)
	var X_INC = snapped(3.0 * build_scale, 0.001)
	var HALF_Y = snapped(0.865 * build_scale, 0.001)
	var HALF_X = snapped(1.5 * build_scale, 0.001)
	
	var MAX_X = snapped(X_INC * size, 0.001)
	var MAX_Y = snapped(Y_INC * (size + y_mod) + HALF_Y, 0.001)
	
	var uv_div = size * build_scale
	
	var x_offset = snapped(MAX_X / 2, 0.001)
	var y_offset = snapped(MAX_Y / 2, 0.001)
	
	var vertices = []
	var indices_buffer = []
	var ind_track = 0
	var chevron_buffer = []
	var chevrons = []
	
	for i in range(0, 6):
		chevron_buffer.append(i)
	
	for columns in range(0, size):
		
		chevrons.append([])
		
		for chev in range(0, size + y_mod):
			
			if columns == 0 and chev == 0:
			
				vertices.append(Vector2(snapped(0 - x_offset, 0.00), snapped(0 - y_offset, 0.00))) # point 0
				vertices.append(Vector2(snapped(0 - x_offset, 0.00), snapped(Y_INC - y_offset, 0.00))) # point 1
				vertices.append(Vector2(snapped(HALF_X - x_offset, 0.00), snapped(HALF_Y - y_offset, 0.00))) # point 2
				vertices.append(Vector2(snapped(HALF_X - x_offset, 0.00), snapped(Y_INC + HALF_Y - y_offset, 0.00))) # point 3
				vertices.append(Vector2(snapped(X_INC - x_offset, 0.00), snapped(0 - y_offset, 0.00))) # point 4
				vertices.append(Vector2(snapped(X_INC - x_offset, 0.00), snapped(Y_INC - y_offset, 0.00))) # point 5
				
				ind_track = 6
				
				chevrons[0].append(chevron_buffer.duplicate())
				
			elif columns == 0:				
				
				var under_chev = chevrons[0][chev - 1]
				
				chevron_buffer[0] = under_chev[1]
				vertices.append(Vector2(snapped(0 - x_offset, 0.00), snapped((vertices[under_chev[1]][1] + Y_INC), 0.00))) # point 1
				chevron_buffer[1] = ind_track
				chevron_buffer[2] = under_chev[3]
				vertices.append(Vector2(snapped(HALF_X - x_offset, 0.00), snapped((vertices[under_chev[3]][1] + Y_INC), 0.00))) # point 3
				chevron_buffer[3] = ind_track + 1
				chevron_buffer[4] = under_chev[5]
				vertices.append(Vector2(snapped(X_INC - x_offset, 0.00), snapped((vertices[under_chev[5]][1] + Y_INC), 0.00))) # point 5
				chevron_buffer[5] = ind_track + 2
				
				ind_track += 3
				
				chevrons[0].append(chevron_buffer.duplicate())
				
			elif columns > 0 and chev == 0:
				
				var left_chev = chevrons[columns - 1][0]
				
				chevron_buffer[0] = left_chev[4]
				chevron_buffer[1] = left_chev[5]
				vertices.append(Vector2(snapped((vertices[left_chev[2]][0] + X_INC), 0.00), snapped(HALF_Y - y_offset, 0.00))) # point 2
				chevron_buffer[2] = ind_track
				vertices.append(Vector2(snapped((vertices[left_chev[3]][0] + X_INC), 0.00), snapped((Y_INC + HALF_Y) - y_offset, 0.00))) # point 3
				chevron_buffer[3] = ind_track + 1
				vertices.append(Vector2(snapped((vertices[left_chev[4]][0] + X_INC), 0.00), snapped(0 - y_offset, 0.00))) # point 4
				chevron_buffer[4] = ind_track + 2
				vertices.append(Vector2(snapped((vertices[left_chev[5]][0] + X_INC), 0.00), snapped(Y_INC - y_offset, 0.00))) # point 5
				chevron_buffer[5] = ind_track + 3
				
				ind_track += 4
				
				chevrons[columns].append(chevron_buffer.duplicate())
				
			elif columns > 0 and chev > 0:
				
				var under_chev = chevrons[columns][chev - 1]
				var left_chev = chevrons[columns - 1][chev]
				
				chevron_buffer[0] = left_chev[4]
				chevron_buffer[1] = left_chev[5]
				chevron_buffer[2] = under_chev[3]
				vertices.append(Vector2(snapped((vertices[left_chev[3]][0] + X_INC), 0.00), snapped((vertices[under_chev[3]][1] + Y_INC), 0.00))) # point 3
				chevron_buffer[3] = ind_track
				chevron_buffer[4] = under_chev[5]
				vertices.append(Vector2(snapped((vertices[left_chev[5]][0] + X_INC), 0.00), snapped((vertices[under_chev[5]][1] + Y_INC), 0.00))) # point 5
				chevron_buffer[5] = ind_track + 1
				
				ind_track += 2
				
				chevrons[columns].append(chevron_buffer.duplicate())
				
			if columns == 0 and chev == 0:
				# left and bottom
				right.append(chevron_buffer[0])
				right.append(chevron_buffer[1])
				bottom.append(chevron_buffer[0])
				bottom.append(chevron_buffer[2])
				bottom.append(chevron_buffer[4])
				
			elif columns == 0 and chev == (size + y_mod - 1):
				# upper left and top
				right.append(chevron_buffer[1])
				top.append(chevron_buffer[1])
				top.append(chevron_buffer[3])
				top.append(chevron_buffer[5])
				
			elif columns == 0 and chev > 0:
				# upper left
				right.append(chevron_buffer[1])
				
			elif columns == (size - 1) and chev == 0:
				# right and bottom
				left.append(chevron_buffer[4])
				left.append(chevron_buffer[5])
				bottom.append(chevron_buffer[2])
				bottom.append(chevron_buffer[4])
				
			elif columns == (size - 1) and chev == (size + y_mod - 1):
				# upper right and top
				left.append(chevron_buffer[5])
				top.append(chevron_buffer[3])
				top.append(chevron_buffer[5])
			
			elif columns == (size - 1) and chev > 0:
				# upper right
				left.append(chevron_buffer[5])
				
			elif columns > 0 and chev == 0:
				# bottom
				bottom.append(chevron_buffer[2])
				bottom.append(chevron_buffer[4])
				
			elif columns > 0 and chev == (size + y_mod - 1):
				# top
				top.append(chevron_buffer[3])
				top.append(chevron_buffer[5])
			
			indices_buffer.append(chevron_buffer[0])
			indices_buffer.append(chevron_buffer[2])
			indices_buffer.append(chevron_buffer[1])
			indices_buffer.append(chevron_buffer[1])
			indices_buffer.append(chevron_buffer[2])
			indices_buffer.append(chevron_buffer[3])
			indices_buffer.append(chevron_buffer[2])
			indices_buffer.append(chevron_buffer[4])
			indices_buffer.append(chevron_buffer[5])
			indices_buffer.append(chevron_buffer[2])
			indices_buffer.append(chevron_buffer[5])
			indices_buffer.append(chevron_buffer[3])
				
	var vertice_return = []
	var normal_return = []
	var uv_return = []
		
	for vert in vertices:
		var y = 0
		vertice_return.append(Vector3(vert[0], y, snapped(vert[1], 0.001)))
		uv_return.append(Vector2(vert[0] / uv_div * uv_multiplier, vert[1] / uv_div * uv_multiplier))
	
	for vert in vertice_return:
		var normal_vert = Vector3(vert[0] + offset.x, vert[1], snapped((vert[2] + offset.z), 0.001))
		normal_return.append(normal_vert.normalized())
	
	var changed_verts = []
	
	edges = terrain_map.get_edges(terrain_map.chunk_list[chunk][1])
		
	if edges[0]:
		for index in top:
			for vert in edges[0]:
				if vertice_return[index][0] == vert[0]:
					vertice_return[index][1] = vert[1]
					changed_verts.append(vertice_return[index])
					break
	if edges[1]:
		for index in bottom:
			for vert in edges[1]:
				if vertice_return[index][0] == vert[0]:
					vertice_return[index][1] = vert[1]
					changed_verts.append(vertice_return[index])
					break
					
	if edges[2]:
		for index in left:
			for vert in edges[2]:
				if abs(vertice_return[index][2] - vert[2]) < 0.002:
					vertice_return[index][1] = vert[1]
					changed_verts.append(vertice_return[index])
	if edges[3]:
		for index in right:
			for vert in edges[3]:
				if abs(vertice_return[index][2] - vert[2]) < 0.002:
					vertice_return[index][1] = vert[1]
					changed_verts.append(vertice_return[index])
	
	var edge_verts = []
	
	for i in range(0, 4):
		edge_verts.append([])
		
	for t_vert in top:
		if vertice_return[t_vert] not in edge_verts[0]:
			edge_verts[0].append(vertice_return[t_vert])
	for b_vert in bottom:
		if vertice_return[b_vert] not in edge_verts[1]:
			edge_verts[1].append(vertice_return[b_vert])
	for l_vert in left:
		if vertice_return[l_vert] not in edge_verts[2]:
			edge_verts[2].append(vertice_return[l_vert])
	for r_vert in right:
		if vertice_return[r_vert] not in edge_verts[3]:
			edge_verts[3].append(vertice_return[r_vert])
		
	var return_array = []
	
	return_array.append(vertice_return.duplicate())
	return_array.append(uv_return.duplicate())
	return_array.append(normal_return.duplicate())
	return_array.append(indices_buffer.duplicate())
	
	return [return_array, edge_verts]
	
func extract_heights(edges):
	
	var return_edges = []
	
	for edge in range(0, 4):
		return_edges.append([])
		if edges[edge]:
			for vert in edges[edge]:
				return_edges[edge].append(snapped(vert[1], 0.001))
			
	return return_edges
