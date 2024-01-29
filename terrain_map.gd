class_name TerrainMap

# variables and constants
var size
var x_max
var z_max
var terrain_map = []
var chunk_list = []
var tracker = 0

var pointer = preload("res://pointer.tscn")
var pointers = []


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
	
class Vert:
	
	var index
	var point
	var neighbors = []
	var is_peak = false
	var peak_steps = []
	
	func _init(v_index, v_point):
		
		index = v_index
		point = v_point
		
class VertRef:
	
	var chunk
	var index
	var is_vetref = true
	
	func _init(v_chunk, v_index):
		
		chunk = v_chunk
		index = v_index
		
	func vertref_compare(comp_ref):
		
		if comp_ref.chunk == chunk and comp_ref.index == index:
			return true
			
		else:
			return false

class TerrainChunk:
	
	var chunk_name = null
	var origin:Vector3
	var map_position:Vector2
	var edges
	var status
	var parent_map
	var vert_map = VertMap.new(self)
	
	func _init(new_origin, posiiton, parent):
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

class VertMap:
	
	var parent_chunk
	var verts = []
	
	func _init(parent):
		
		parent_chunk = parent
		
	func get_linked_verts(link_vert):
		
		for vert in verts:
			if vert.point == link_vert:
				return vert.neighbors.duplicate()
				
	func make_mountains(peak_density, peak_modifier):
		
		var new_peaks = [] 
		
		for vert in verts:
			var rand_gen = RandomNumberGenerator.new()
			var peak_chance = rand_gen.randi() % 100
			if peak_chance <= peak_density:
				vert.is_peak = true
				
		var fill_inc = 1
		
		var step_one_tracker = []
		var step_peak
		
		for vert in verts:
			step_peak = false
			if not vert.is_peak:
				for neighbor in vert.neighbors:
					if parent_chunk.parent_map.terrain_map[neighbor.chunk[0]][neighbor.chunk[1]].vert_map.verts[neighbor.index].is_peak:
						vert.peak_steps.append([VertRef.new(neighbor.chunk, neighbor.index), 1])
						step_peak = true
			if step_peak:
				step_one_tracker.append(vert)
						
		while fill_inc < parent_chunk.parent_map.size + 1:
			
			var step_tracker = []
			
			for vert in verts:
				step_peak = false
				if not vert.is_peak:
					for neighbor in vert.neighbors:
						for ref in parent_chunk.parent_map.terrain_map[neighbor.chunk[0]][neighbor.chunk[1]].vert_map.verts[neighbor.index].peak_steps:
							if ref[1] == fill_inc:
								if len(vert.peak_steps) > 0:
									pass
								else:
									vert.peak_steps.append([VertRef.new(ref[0].chunk, ref[0].index), fill_inc + 1])
									step_tracker.append(vert)
									step_peak = true
									
			fill_inc += 1
										
		var max_peak = parent_chunk.parent_map.size * peak_modifier
		
		for vert in verts:
			
			var new_z
			
			if vert.is_peak:
				new_z = max_peak
			else:
				if len(vert.peak_steps) > 0:
					var steps = 0
					for step in vert.peak_steps:
						new_z = step[1] * peak_modifier
				else:
					new_z = 0
					
					
			var new_vert = Vector3(vert.point[0], vert.point[1] + new_z, vert.point[2])
			
			new_peaks.append(new_vert)
			vert.point = new_vert
			
		return new_peaks
	
	func fill(vert_list, xinc, zinc, size ):
		
		var half_x = xinc / 2
		var half_z = zinc / 2
		var z_mod = int(size * 0.66)
		var xmax = (xinc * size) / 2
		var zmax = snapped(((zinc * (size + z_mod)) + half_z) / 2, 0.001)
		var zlim  = snapped(zmax - half_z, 0.001)
		var xmin = 0 - (half_x * size)
		var zmin = snapped(0 - zmax, 0.001)
		
		for fill_vert in range(0, len(vert_list)):
			
			var new_vert = Vert.new(fill_vert, vert_list[fill_vert])
		
			var neighbors = parent_chunk.parent_map.get_edges(parent_chunk.map_position, true)
			
			var nwest
			var north
			var neast
			var seast
			var south
			var swest
			
			if vert_list[fill_vert][0] == xmin:
				if snapped(vert_list[fill_vert][2], 0.001) < zlim - 0.005:
					north = Vector2(vert_list[fill_vert][0], snapped(vert_list[fill_vert][2] + zinc, 0.001))
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(north, vert_list, fill_vert, "north1")))
					
				neast = Vector2(vert_list[fill_vert][0] + half_x, snapped(vert_list[fill_vert][2] + half_z, 0.001))
				new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(neast, vert_list, fill_vert, "neast1")))
				
				if snapped(vert_list[fill_vert][2], 0.001) > zmin:
					seast = Vector2(vert_list[fill_vert][0] + half_x, snapped(vert_list[fill_vert][2] - half_z, 0.001))
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(seast, vert_list, fill_vert, "seast1")))
					
					south = Vector2(vert_list[fill_vert][0], snapped(vert_list[fill_vert][2] - zinc, 0.001))
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(south, vert_list, fill_vert, "south1")))
					
				if neighbors[2]:
					var links = parent_chunk.parent_map.get_linked_verts(Vector2(neighbors[2][0], neighbors[2][1]), vert_list[fill_vert])
					if links:
						for link in links:
							new_vert.neighbors.append(link)
					
				if snapped(vert_list[fill_vert][2], 0.001) == zmin and neighbors[1]:
					var links = parent_chunk.parent_map.get_linked_verts(Vector2(neighbors[1][0], neighbors[1][1]), vert_list[fill_vert])
					if links:
						for link in links:
							new_vert.neighbors.append(link)
					
				if vert_list[fill_vert][0] == xmin and neighbors[0]:
					var links = parent_chunk.parent_map.get_linked_verts(Vector2(neighbors[0][0], neighbors[0][1]), vert_list[fill_vert])
					if links:
						for link in links:
							new_vert.neighbors.append(link)
					
			elif vert_list[fill_vert][0] > xmin and vert_list[fill_vert][0] < xmax:
				if snapped(vert_list[fill_vert][2], 0.001) < zlim - 0.005:
					north = Vector2(vert_list[fill_vert][0], snapped(vert_list[fill_vert][2] + zinc, 0.001))
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(north, vert_list, fill_vert, "north2")))
					
				if snapped(vert_list[fill_vert][2], 0.001) < zlim + half_z - 0.005:
					neast = Vector2(vert_list[fill_vert][0] + half_x, snapped(vert_list[fill_vert][2] + half_z, 0.001))
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(neast, vert_list, fill_vert, "neast2")))
					
					nwest = Vector2(vert_list[fill_vert][0] - half_x, snapped(vert_list[fill_vert][2] + half_z, 0.001))
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(nwest, vert_list, fill_vert, "nwest2")))
				
				if snapped(vert_list[fill_vert][2], 0.001) > zmin:
					seast = Vector2(vert_list[fill_vert][0] + half_x, snapped(vert_list[fill_vert][2] - half_z, 0.001))
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(seast, vert_list, fill_vert, "seast2")))
					
					swest = Vector2(vert_list[fill_vert][0] - half_x, snapped(vert_list[fill_vert][2] - half_z, 0.001))
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(swest, vert_list, fill_vert, "swest2")))
					
				if snapped(vert_list[fill_vert][2], 0.001) > zmin + half_z + 0.005:
					south = Vector2(vert_list[fill_vert][0], snapped(vert_list[fill_vert][2] - zinc, 0.001))
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(south, vert_list, fill_vert, "south2")))
					
				if snapped(vert_list[fill_vert][2], 0.001) >= zlim and neighbors[0]:
					var links = parent_chunk.parent_map.get_linked_verts(Vector2(neighbors[0][0], neighbors[0][1]), vert_list[fill_vert])
					if links:
						for link in links:
							new_vert.neighbors.append(link)
					
				if snapped(vert_list[fill_vert][2], 0.001) <= half_z and neighbors[1]:
					var links = parent_chunk.parent_map.get_linked_verts(Vector2(neighbors[1][0], neighbors[1][1]), vert_list[fill_vert])
					if links:
						for link in links:
							new_vert.neighbors.append(link)
				
			elif vert_list[fill_vert][0] == xmax:
				if snapped(vert_list[fill_vert][2], 0.001) < zlim - 0.005:
					north = Vector2(vert_list[fill_vert][0], snapped(vert_list[fill_vert][2] + zinc, 0.001))
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(north, vert_list, fill_vert, "north3")))
					
				nwest = Vector2(vert_list[fill_vert][0] - half_x, snapped(vert_list[fill_vert][2] + half_z, 0.001))
				new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(nwest, vert_list, fill_vert, "nwest3")))
				
				if snapped(vert_list[fill_vert][2], 0.001) > zmin:
					swest = Vector2(vert_list[fill_vert][0] - half_x, snapped(vert_list[fill_vert][2] - half_z, 0.001))
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(swest, vert_list, fill_vert, "swest3")))
					
					south = Vector2(vert_list[fill_vert][0], snapped(vert_list[fill_vert][2] - zinc, 0.001))
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(south, vert_list, fill_vert, "south3")))
					
				if neighbors[3]:
					var links = parent_chunk.parent_map.get_linked_verts(Vector2(neighbors[3][0], neighbors[3][1]), vert_list[fill_vert])
					if links:
						for link in links:
							new_vert.neighbors.append(link)
					
				if snapped(vert_list[fill_vert][2], 0.001) == zmin and neighbors[1]:
					var links = parent_chunk.parent_map.get_linked_verts(Vector2(neighbors[1][0], neighbors[1][1]), vert_list[fill_vert])
					if links:
						for link in links:
							new_vert.neighbors.append(link)
					
				if snapped(vert_list[fill_vert][0], 0.001) == xmin and neighbors[0]:
					var links = parent_chunk.parent_map.get_linked_verts(Vector2(neighbors[0][0], neighbors[0][1]), vert_list[fill_vert])
					if links:
						for link in links:
							new_vert.neighbors.append(link)
							
			verts.append(new_vert)
						
	func get_index(v_point, v_list, index, direction=''):
				
		for i in range(0, len(v_list)):
			if v_list[i][0] == v_point[0]:
				if snapped(v_list[i][2], 0.001) < snapped(v_point[1], 0.001) + 0.005 and snapped(v_list[i][2], 0.001) > snapped(v_point[1], 0.001) - 0.005:
					return i
