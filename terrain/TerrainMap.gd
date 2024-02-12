extends Node
class_name TerrainMap

# variables and constants
var size
var x_max
var z_max
var terrain_map = []
var chunk_list = []
var tracker = 0


func _init(xmax, zmax, mesh_size):
	x_max = xmax
	z_max = zmax
	size = mesh_size
	terrain_map.append([])
	terrain_map[0].append(TerrainChunk.new(Vector3(0, 0 ,0), Vector2(0, 0), self))
	chunk_list.append([Vector3(0, 0, 0), Vector2(0, 0)])
	
func activate_chunk(position, name, edges):
	
	var chunk_positions = []
	for pos in chunk_list:
		chunk_positions.append(pos[0])
	
	for chunk in chunk_list:
		if chunk[0] == position:
			
			terrain_map[chunk[1][0]][chunk[1][1]].activate(name, edges)
			
			var z = snapped(position.z, 0.001)
			
			var test_list = [
				Vector3(position.x - x_max, 0, z),
				Vector3(position.x - x_max, 0, z + z_max),
				Vector3(position.x, 0, z + z_max),
				Vector3(position.x + x_max, 0, z + z_max),
				Vector3(position.x + x_max, 0, z),
				Vector3(position.x + x_max, 0, z - z_max),
				Vector3(position.x, 0, z - z_max),
				Vector3(position.x - x_max, 0, z - z_max)
			]
			
			for out_chunk in test_list:
				if out_chunk not in chunk_positions:
					var out_map_pos = convert_map_coords(Vector2(out_chunk.x / x_max, out_chunk.z / z_max), out_chunk)
					add_chunk(out_chunk, out_map_pos)
			
func get_all_chunks():
	
	return chunk_list.duplicate()
	
func get_status(map_position):
	
	return terrain_map[map_position[0]][map_position[1]].status
	
func get_edges(map_position, neighbors=false):
	
	var return_edges = [null, null, null, null]
	
	var a = map_position[0]
	var b = map_position[1]
	var c = false
	
	var top = null
	var bottom = null
	var left = null
	var right = null
	
	if len(terrain_map) > a + 1:
		c = true
	
	if a > 0:
		
		if b < a or b > (a * 7):
			if b >= 0 and b < a:
				if c:
					if terrain_map[a + 1][b]:
						if terrain_map[a + 1][b].status:
							return_edges[3] = terrain_map[a + 1][b].edges[2]
							right = Vector2(a + 1, b)
				if terrain_map[a - 1][b]:
					if terrain_map[a - 1][b].status:
						return_edges[2] = terrain_map[a - 1][b].edges[3]
						left = Vector2(a - 1, b)
				if terrain_map[a][b + 1]:
					if terrain_map[a][b + 1].status:
						return_edges[1] = terrain_map[a][b + 1].edges[0]
						bottom = Vector2(a, b + 1)
				if b > 0:
					if terrain_map[a][b - 1]:
						if terrain_map[a][b - 1].status:
							return_edges[0] = terrain_map[a][b - 1].edges[1]
							top = Vector2(a, b + 1)
				if b == 0:
					if terrain_map[a][(a * 8) - 1]:
						if terrain_map[a][(a * 8) - 1].status:
							return_edges[0] = terrain_map[a][(a * 8) - 1].edges[1]
							top = Vector2(a, (a * 8) - 1)
			if b > (a * 7):
				if terrain_map[a - 1][b - 8]:
					if terrain_map[a - 1][b - 8].status:
						return_edges[2] = terrain_map[a - 1][b - 8].edges[3]
						left = Vector2(a - 1, b - 8)
				if c:
					if terrain_map[a + 1][b + 8]:
						if terrain_map[a + 1][b + 8].status:
							return_edges[3] = terrain_map[a + 1][b + 8].edges[2]
							right = Vector2(a + 1, b + 8)
				if terrain_map[a][b - 1].status:
					if terrain_map[a][b - 1].status:
						return_edges[0] = terrain_map[a][b - 1].edges[1]
						top = Vector2(a, b - 1)
				if b == (a * 8) - 1:
					if terrain_map[a][0]:
						if terrain_map[a][0].status:
							return_edges[1] = terrain_map[a][0].edges[0]
							bottom = Vector2(a, 0)
				if b < (a * 8) - 1:
					if terrain_map[a][b + 1]:
						if terrain_map[a][b + 1].status:
							return_edges[1] = terrain_map[a][b + 1].edges[0]
							bottom = Vector2(a, b + 1)
		elif b > a and b < (a * 3):
			if terrain_map[a][b - 1]:
				if terrain_map[a][b - 1].status:
					return_edges[3] = terrain_map[a][b - 1].edges[2]
					right = Vector2(a, b - 1)
			if terrain_map[a][b + 1]:
				if terrain_map[a][b + 1].status:
					return_edges[2] = terrain_map[a][b + 1].edges[3]
					left = Vector2(a, b + 1)
			if terrain_map[a - 1][b - 2]:
				if terrain_map[a - 1][b - 2].status:
					return_edges[0] = terrain_map[a - 1][b - 2].edges[1]
					top = Vector2(a - 1, b - 2)
			if c:
				if terrain_map[a + 1][b + 2]:
					if terrain_map[a + 1][b + 2].status:
						return_edges[1] = terrain_map[a + 1][b + 2].edges[0]
						bottom = Vector2(a + 1, b + 2)
		elif b > (a * 3) and b < (a * 5):
			if terrain_map[a][b - 1]:
				if terrain_map[a][b - 1].status:
					return_edges[1] = terrain_map[a][b - 1].edges[0]
					bottom = Vector2(a, b - 1)
			if terrain_map[a][b + 1]:
				if terrain_map[a][b + 1].status:
					return_edges[0] = terrain_map[a][b + 1].edges[1]
					top = Vector2(a, b + 1)
			if terrain_map[a - 1][b - 4]:
				if terrain_map[a - 1][b - 4].status:
					return_edges[3] = terrain_map[a - 1][b - 4].edges[2]
					right = Vector2(a - 1, b - 4)
			if c:
				if terrain_map[a + 1][b + 4]:
					if terrain_map[a + 1][b + 4].status:
						return_edges[2] = terrain_map[a + 1][b + 4].edges[3]
						left = Vector2(a + 1, b + 4)
		elif b > (a * 5) and b < (a * 7):
			if terrain_map[a][b - 1]:
				if terrain_map[a][b - 1].status:
					return_edges[2] = terrain_map[a][b - 1].edges[3]
					left = Vector2(a, b - 1)
			if terrain_map[a][b + 1]:
				if terrain_map[a][b + 1].status:
					return_edges[3] = terrain_map[a][b + 1].edges[2]
					right = Vector2(a, b + 1)
			if terrain_map[a - 1][b - 6]:
				if terrain_map[a - 1][b - 6].status:
					return_edges[1] = terrain_map[a - 1][b - 6].edges[0]
					bottom = Vector2(a - 1, b - 6)
			if c:
				if terrain_map[a + 1][b + 6]:
					if terrain_map[a + 1][b + 6].status:
						return_edges[0] = terrain_map[a + 1][b + 6].edges[1]
						top = Vector2(a + 1, b + 6)
		elif b == a:
			if terrain_map[a][b - 1]:
				if terrain_map[a][b - 1].status:
					return_edges[0] = terrain_map[a][b - 1].edges[1]
					top = Vector2(a, b - 1)
			if terrain_map[a][b + 1]:
				if terrain_map[a][b + 1].status:
					return_edges[2] = terrain_map[a][b + 1].edges[3]
					left = Vector2(a, b + 1)
			if terrain_map[a + 1][b]:
				if terrain_map[a + 1][b].status:
					return_edges[3] = terrain_map[a + 1][b].edges[2]
					right = Vector2(a + 1, b)
			if c:
				if terrain_map[a + 1][b + 2]:
					if terrain_map[a + 1][b + 2].status:
						return_edges[1] = terrain_map[a + 1][b].edges[0]
						bottom = Vector2(a + 1, b)
		elif b == a * 3:
			if terrain_map[a][b - 1]:
				if terrain_map[a][b - 1].status:
					return_edges[3] = terrain_map[a][b - 1].edges[2]
					right = Vector2(a, b - 1)
			if terrain_map[a][b + 1]:
				if terrain_map[a][b + 1].status:
					return_edges[0] = terrain_map[a][b + 1].edges[1]
					top = Vector2(a, b + 1)
			if c:
				if terrain_map[a + 1][b + 2]:
					if terrain_map[a + 1][b + 2].status:
						return_edges[1] = terrain_map[a + 1][b + 2].edges[0]
						bottom = Vector2(a + 1, b + 2)
				if terrain_map[a + 1][b + 4]:
					if terrain_map[a + 1][b + 4].status:
						return_edges[2] = terrain_map[a + 1][b].edges[3]
						left = Vector2(a + 1, b)
		elif b == a * 5:
			if terrain_map[a][b - 1]:
				if terrain_map[a][b - 1].status:
					return_edges[1] = terrain_map[a][b - 1].edges[0]
					bottom = Vector2(a, b - 1)
			if terrain_map[a][b + 1]:
				if terrain_map[a][b + 1].status:
					return_edges[3] = terrain_map[a][b + 1].edges[2]
					right = Vector2(a, b - 1)
			if c:
				if terrain_map[a + 1][b + 4]:
					if terrain_map[a + 1][b + 4].status:
						return_edges[2] = terrain_map[a + 1][b].edges[3]
						left = Vector2(a + 1, b + 4)
				if terrain_map[a + 1][b + 6]:
					if terrain_map[a + 1][b + 6].status:
						return_edges[0] = terrain_map[a + 1][b].edges[1]
						top = Vector2(a + 1, b)
		elif b == a * 7:
			if terrain_map[a][b - 1]:
				if terrain_map[a][b - 1].status:
					return_edges[2] = terrain_map[a][b - 1].edges[3]
					left = Vector2(a, b - 1)
			if a == 1:
				if terrain_map[a][0]:
					if terrain_map[a][0].status:
						return_edges[1] = terrain_map[a][0].edges[0]
						bottom = Vector2(a, 0)
			else:
				if terrain_map[a][b + 1]:
					if terrain_map[a][b + 1].status:
						return_edges[1] = terrain_map[a][b + 1].edges[0]
						bottom = Vector2(a, b + 1)
			if c:
				if terrain_map[a + 1][b + 6]:
					if terrain_map[a + 1][b + 6].status:
						return_edges[0] = terrain_map[a + 1][b].edges[1]
						top = Vector2(a + 1, b)
				if terrain_map[a + 1][b + 8]:
					if terrain_map[a + 1][b + 8].status:
						return_edges[3] = terrain_map[a + 1][b].edges[2]
						right = Vector2(a + 1, b)
	
	var neighbor_return = [top, bottom, left, right]
	
	if neighbors:
		return neighbor_return
			
	else:
		return return_edges
	

func add_chunk(position, map_position):
	
	if map_position[0] >= len(terrain_map):
		terrain_map.append([])
		for i in range(0, map_position[0] * 8):
			terrain_map[map_position[0]].append(null)
			
	terrain_map[map_position[0]][map_position[1]] = TerrainChunk.new(position, map_position, self)
	chunk_list.append([position, map_position])
	
func convert_map_coords(coords, _position):
	
	var m
	var x = coords[0]
	var z = coords[1]
	var index
	
	if abs(coords[0]) >= abs(coords[1]):
		m = abs(coords[0])
	else:
		m = abs(coords[1])
		
	var m_min = m - (2 * m)
	
	if z == m:
		index = (m * 6) - x
	elif z == m_min:
		index = (m * 2) + x
	elif x == m:
		index = (m * 4) + z
	elif x == m_min:
		if z <= 0:
			index = abs(z)
		else:
			index = (m * 8) - z
		
	var result = Vector2(m, index)
	
	return result
	
func get_linked_verts(position, vert):
	
	return  terrain_map[position[0]][position[1]].get_linked_verts(vert)
	
func reset(xmax, zmax, mesh_size):
	
	x_max = xmax
	z_max = zmax
	size = mesh_size
	terrain_map = []
	chunk_list = []
	tracker = 0
	terrain_map.append([])
	terrain_map[0].append(TerrainChunk.new(Vector3(0, 0 ,0), Vector2(0, 0), self))
	chunk_list.append([Vector3(0, 0, 0), Vector2(0, 0)])
	

class TerrainChunk:
	
	
	var vert_map_class = preload("res://terrain/VertMap.gd")
	
	var chunk_name = null
	var origin:Vector3
	var map_position:Vector2
	var edges
	var status
	var parent_map
	var vert_map = vert_map_class.new()
	
	func _init(new_origin, posiiton, parent):		
		vert_map.parent_chunk = self
		origin = new_origin
		map_position = posiiton
		status = false
		parent_map = parent
		
		
	func fill_vert_map(vert_list, xinc, zinc, size):
		
		vert_map.fill(vert_list, xinc, zinc, size)
	
	func make_mountains(peak_density, peak_modifier):
		
		return vert_map.make_mountains(peak_density, peak_modifier)
		
	func activate(name, edge_list):
		chunk_name = name
		status = true
		edges = edge_list
		
	func get_linked_verts(vert):
		
		return vert_map.get_linked_verts(vert)
