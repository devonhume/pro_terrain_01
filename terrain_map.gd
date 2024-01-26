class_name TerrainMap

# variables and constants
var size
var x_max
var z_max
var terrain_map = []
var chunk_list = []
var tracker = 0

func _init(xmax, zmax, mesh_size):
	print("terrain_map init, xmax: ", xmax, ", zmax: ", zmax)
	x_max = xmax
	z_max = zmax
	size = mesh_size
	terrain_map.append([])
	terrain_map[0].append(TerrainChunk.new(Vector3(0, 0 ,0), Vector2(0, 0), self))
	chunk_list.append([Vector3(0, 0, 0), Vector2(0, 0)])
	
func print_chunks():
	for chunk in chunk_list:
		if chunk[1][0] > 1 and chunk[1][0] < 3:
			if chunk[1][1] > chunk[1][0] * 7 or chunk[1][1] < chunk[1][0]:
				print("Tier: ", chunk[1][0], ", Chunk: ", chunk[1][1], ", Origin: ", chunk[0], ", ", chunk[1])
				var edges = terrain_map[chunk[1][0]][chunk[1][1]].edges# get_edges(chunk[1])
				# print("edges: ", edges)
				var north_edges = []
				var south_edges = []
				var east_edges = []
				var west_edges = []
				if edges:
					if edges[0]:
						for n_vert in edges[0]:
							north_edges.append(snapped(n_vert[1], 0.001))
					if edges[1]:
						for s_vert in edges[1]:
							south_edges.append(snapped(s_vert[1], 0.001))
					if edges[2]:
						for e_vert in edges[2]:
							east_edges.append(snapped(e_vert[1], 0.001))
					if edges[3]:
						for w_vert in edges[3]:
							west_edges.append(snapped(w_vert[1], 0.001))
				print("north: ", north_edges)
				print("south: ", south_edges)
				print("east: ", east_edges)
				print("west: ", west_edges)
				print(get_edges(chunk[1], true))
	
func activate_chunk(position, name, edges):
	
	# print("activate_chunk: ", position, ", ", name)
	# print("edges: ", edges)
	# print("terrain_map: ", terrain_map)
	
	var chunk_positions = []
	for pos in chunk_list:
		chunk_positions.append(pos[0])
	
	for chunk in chunk_list:
		if chunk[0] == position:
			
			# print("activating ", chunk)
			
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
			
			# print("test_list: ", test_list)
			# print("position.z: ", position.z, ", z_max: ", z_max)
			
			for out_chunk in test_list:
				if out_chunk not in chunk_positions:
					var out_map_pos = convert_map_coords(Vector2(out_chunk.x / x_max, out_chunk.z / z_max), out_chunk)
					# print("adding chunk: ", out_chunk, ", ", out_map_pos)
					add_chunk(out_chunk, out_map_pos)
					
					
	# print("chunk_list: ", get_all_chunks())
			
func get_all_chunks():
	
	return chunk_list.duplicate()
	
func get_status(map_position):
	
	return terrain_map[map_position[0]][map_position[1]].status
	
func get_edges(map_position, neighbors=false):
	
	var return_edges = [null, null, null, null]
	
	var a = map_position[0]
	var b = map_position[1]
	var c = false
	
	# print("a: ", a, ", b: ", b)
	
	var top = null
	var bottom = null
	var left = null
	var right = null
	
	if len(terrain_map) > a + 1:
		c = true
	
	if a > 0:
		
		if b < a or b > (a * 7):
			# print("0")
			if b >= 0 and b < a:
				# print("b: ", b)
				if c:
					if terrain_map[a + 1][b]:
						if terrain_map[a + 1][b].status:
							return_edges[3] = terrain_map[a + 1][b].edges[2]
							right = Vector2(a + 1, b)
							# print("right: ", right)
				if terrain_map[a - 1][b]:
					if terrain_map[a - 1][b].status:
						return_edges[2] = terrain_map[a - 1][b].edges[3]
						left = Vector2(a - 1, b)
						# print("left: ", left)
				if terrain_map[a][b + 1]:
					if terrain_map[a][b + 1].status:
						return_edges[1] = terrain_map[a][b + 1].edges[0]
						bottom = Vector2(a, b + 1)
						# print("bottom: ", bottom)
				if b > 0:
					if terrain_map[a][b - 1]:
						if terrain_map[a][b - 1].status:
							return_edges[0] = terrain_map[a][b - 1].edges[1]
							top = Vector2(a, b + 1)
							# print("top: ", top)
				if b == 0:
					if terrain_map[a][(a * 8) - 1]:
						if terrain_map[a][(a * 8) - 1].status:
							return_edges[0] = terrain_map[a][(a * 8) - 1].edges[1]
							top = Vector2(a, (a * 8) - 1)
							# print("top: ", top)
			if b > (a * 7):
				if terrain_map[a - 1][b - 8]:
					if terrain_map[a - 1][b - 8].status:
						return_edges[2] = terrain_map[a - 1][b - 8].edges[3]
						left = Vector2(a - 1, b - 8)
						# print("left: ", left)
				if c:
					if terrain_map[a + 1][b + 8]:
						if terrain_map[a + 1][b + 8].status:
							return_edges[3] = terrain_map[a + 1][b + 8].edges[2]
							right = Vector2(a + 1, b + 8)
							# print("right: ", right)
				if terrain_map[a][b - 1].status:
					if terrain_map[a][b - 1].status:
						return_edges[0] = terrain_map[a][b - 1].edges[1]
						top = Vector2(a, b - 1)
						# print("top: ", top)
				if b == (a * 8) - 1:
					if terrain_map[a][0]:
						if terrain_map[a][0].status:
							return_edges[1] = terrain_map[a][0].edges[0]
							bottom = Vector2(a, 0)
							# print("bottom: ", bottom)
				if b < (a * 8) - 1:
					#print("a * 9: ", a * 9, ", b: ", b)
					if terrain_map[a][b + 1]:
						if terrain_map[a][b + 1].status:
							return_edges[1] = terrain_map[a][b + 1].edges[0]
							bottom = Vector2(a, b + 1)
							# print("bottom: ", bottom)
		elif b > a and b < (a * 3):
			# print("1")
			if terrain_map[a][b - 1]:
				if terrain_map[a][b - 1].status:
					return_edges[3] = terrain_map[a][b - 1].edges[2]
					right = Vector2(a, b - 1)
					# print("right: ", right)
			if terrain_map[a][b + 1]:
				if terrain_map[a][b + 1].status:
					return_edges[2] = terrain_map[a][b + 1].edges[3]
					left = Vector2(a, b + 1)
					# print("left: ", left)
			if terrain_map[a - 1][b - 2]:
				if terrain_map[a - 1][b - 2].status:
					return_edges[0] = terrain_map[a - 1][b - 2].edges[1]
					top = Vector2(a - 1, b - 2)
					# print("top: ", top)
			if c:
				if terrain_map[a + 1][b + 2]:
					if terrain_map[a + 1][b + 2].status:
						return_edges[1] = terrain_map[a + 1][b + 2].edges[0]
						bottom = Vector2(a + 1, b + 2)
						# print("bottom: ", bottom)
		elif b > (a * 3) and b < (a * 5):
			# print("2")
			if terrain_map[a][b - 1]:
				if terrain_map[a][b - 1].status:
					return_edges[1] = terrain_map[a][b - 1].edges[0]
					bottom = Vector2(a, b - 1)
					# print("bottom: ", bottom)
			if terrain_map[a][b + 1]:
				if terrain_map[a][b + 1].status:
					return_edges[0] = terrain_map[a][b + 1].edges[1]
					top = Vector2(a, b + 1)
					# print("top: ", top)
			if terrain_map[a - 1][b - 4]:
				if terrain_map[a - 1][b - 4].status:
					return_edges[3] = terrain_map[a - 1][b - 4].edges[2]
					right = Vector2(a - 1, b - 4)
					# print("right: ", right)
			if c:
				if terrain_map[a + 1][b + 4]:
					if terrain_map[a + 1][b + 4].status:
						return_edges[2] = terrain_map[a + 1][b + 4].edges[3]
						left = Vector2(a + 1, b + 4)
						# print("left: ", left)
		elif b > (a * 5) and b < (a * 7):
			# print("3")
			if terrain_map[a][b - 1]:
				if terrain_map[a][b - 1].status:
					return_edges[2] = terrain_map[a][b - 1].edges[3]
					left = Vector2(a, b - 1)
					# print("left: ", left)
			if terrain_map[a][b + 1]:
				if terrain_map[a][b + 1].status:
					return_edges[3] = terrain_map[a][b + 1].edges[2]
					right = Vector2(a, b + 1)
					# print("right: ", right)
			if terrain_map[a - 1][b - 6]:
				if terrain_map[a - 1][b - 6].status:
					return_edges[1] = terrain_map[a - 1][b - 6].edges[0]
					bottom = Vector2(a - 1, b - 6)
					# print("bottom: ", bottom)
			if c:
				if terrain_map[a + 1][b + 6]:
					if terrain_map[a + 1][b + 6].status:
						return_edges[0] = terrain_map[a + 1][b + 6].edges[1]
						top = Vector2(a + 1, b + 6)
						# print("top: ", top)
		elif b == a:
			# print("4")
			if terrain_map[a][b - 1]:
				if terrain_map[a][b - 1].status:
					return_edges[0] = terrain_map[a][b - 1].edges[1]
					top = Vector2(a, b - 1)
					# print("top: ", top)
			if terrain_map[a][b + 1]:
				if terrain_map[a][b + 1].status:
					return_edges[2] = terrain_map[a][b + 1].edges[3]
					left = Vector2(a, b + 1)
					# print("left: ", left)
			if terrain_map[a + 1][b]:
				if terrain_map[a + 1][b].status:
					return_edges[3] = terrain_map[a + 1][b].edges[2]
					right = Vector2(a + 1, b)
					# print("right: ", right)
			if c:
				if terrain_map[a + 1][b + 2]:
					if terrain_map[a + 1][b + 2].status:
						return_edges[1] = terrain_map[a + 1][b].edges[0]
						bottom = Vector2(a + 1, b)
						# print("bottom: ", bottom)
		elif b == a * 3:
			# print("5")
			if terrain_map[a][b - 1]:
				if terrain_map[a][b - 1].status:
					return_edges[3] = terrain_map[a][b - 1].edges[2]
					right = Vector2(a, b - 1)
					# print("right: ", right)
			if terrain_map[a][b + 1]:
				if terrain_map[a][b + 1].status:
					return_edges[0] = terrain_map[a][b + 1].edges[1]
					top = Vector2(a, b + 1)
					# print("top: ", top)
			if c:
				if terrain_map[a + 1][b + 2]:
					if terrain_map[a + 1][b + 2].status:
						return_edges[1] = terrain_map[a + 1][b + 2].edges[0]
						bottom = Vector2(a + 1, b + 2)
						# print("bottom: ", bottom)
				if terrain_map[a + 1][b + 4]:
					if terrain_map[a + 1][b + 4].status:
						return_edges[2] = terrain_map[a + 1][b].edges[3]
						left = Vector2(a + 1, b)
						# print("left: ", left)
		elif b == a * 5:
			# print("6")
			if terrain_map[a][b - 1]:
				if terrain_map[a][b - 1].status:
					return_edges[1] = terrain_map[a][b - 1].edges[0]
					bottom = Vector2(a, b - 1)
					# print("bottom: ", bottom)
			if terrain_map[a][b + 1]:
				if terrain_map[a][b + 1].status:
					return_edges[3] = terrain_map[a][b + 1].edges[2]
					right = Vector2(a, b - 1)
					# print("right: ", right)
			if c:
				if terrain_map[a + 1][b + 4]:
					if terrain_map[a + 1][b + 4].status:
						return_edges[2] = terrain_map[a + 1][b].edges[3]
						left = Vector2(a + 1, b + 4)
						# print("left: ", left)
				if terrain_map[a + 1][b + 6]:
					if terrain_map[a + 1][b + 6].status:
						return_edges[0] = terrain_map[a + 1][b].edges[1]
						top = Vector2(a + 1, b)
						# print("top: ", top)
		elif b == a * 7:
			#print("7")
			if terrain_map[a][b - 1]:
				if terrain_map[a][b - 1].status:
					return_edges[2] = terrain_map[a][b - 1].edges[3]
					left = Vector2(a, b - 1)
					# print("left: ", left)
			if a == 1:
				if terrain_map[a][0]:
					if terrain_map[a][0].status:
						return_edges[1] = terrain_map[a][0].edges[0]
						bottom = Vector2(a, 0)
						# print("bottom 1: ", bottom)
			else:
				if terrain_map[a][b + 1]:
					if terrain_map[a][b + 1].status:
						return_edges[1] = terrain_map[a][b + 1].edges[0]
						bottom = Vector2(a, b + 1)
						# print("bottom 2: ", bottom)
			if c:
				if terrain_map[a + 1][b + 6]:
					if terrain_map[a + 1][b + 6].status:
						return_edges[0] = terrain_map[a + 1][b].edges[1]
						top = Vector2(a + 1, b)
						# print("top: ", top)
				if terrain_map[a + 1][b + 8]:
					if terrain_map[a + 1][b + 8].status:
						return_edges[3] = terrain_map[a + 1][b].edges[2]
						right = Vector2(a + 1, b)
						# print("right: ", right)
						
	# print("return_edges")
	# print("[0]: ", top, " | ", return_edges[0])
	# print("[1]: ", bottom, " | ", return_edges[1])
	# print("[2]: ", left, " | ", return_edges[2])
	# print("[3]: ", right, " | ", return_edges[3])
	
	var neighbor_return = [top, bottom, left, right]
	
	if neighbors:
		# for n in neighbor_return:
			# if n:
				# if n[1] >= n[0] * 8 and n[0] != 0:
					# print("neighbor_return: ", neighbor_return)
		return neighbor_return
			
	else:
		return return_edges
	

func add_chunk(position, map_position):
	
	# print("add_chunk: ", map_position)
	
	if map_position[0] >= len(terrain_map):
		# print("terrain_map len: ", len(terrain_map))
		terrain_map.append([])
		for i in range(0, map_position[0] * 8):
			terrain_map[map_position[0]].append(null)
			# print("terrain_map[", map_position[0], "] len: ", len(terrain_map[map_position[0]]))
			
	#elif map_position[1] >= len(terrain_map[map_position[0]]):		
	#	for i in range(len(terrain_map[map_position[0]]) - 1, map_position[1]):
	#		terrain_map[map_position[0]].append(null)
	#		# print("* terrain_map[", map_position[0], "] len: ", len(terrain_map[map_position[0]]))
	
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
		#index = (m * 2) + x
		index = (m * 6) - x
		# -1, 1 = 1 (7)
		# 0, 1 = 2	(6)
		# 1, 1 = 3 (5)
	elif z == m_min:
		#index = (m * 6) + x
		index = (m * 2) + x
		# -1, -1 = 5 (1)
		# 0, -1 = 6 (2)
		# 1, -1 = 4 (3)
	elif x == m:
		index = (m * 4) + z
		# 1, 0 = 4 (4)
	elif x == m_min:
		if z >= 0:
			index = z
			# -1, 0 = 0 (0)
		else:
			index = (m * 8) + z
		
	# print("pos: ", position, ", m: ", m, ", index: ", index, ", coords: ", coords)
		
	var result = Vector2(m, index)
	
	# print("Coords: ", coords, " Result: ", result)
	
	return result
	
func get_linked_verts(position, vert):
	
	# print("map returning: ", terrain_map[position[0]][position[1]].get_linked_verts(vert))
	
	# print("position: ", position, ", vert: ", vert)
	
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
		
		# print("VertRef - v_chunk: ", v_chunk, ", v-index: ", v_index)
		
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
		
		# print("TerrainChunk.fill_vert_map")
		
		vert_map.fill(vert_list, xinc, zinc, size)
	
	func make_mountains(peak_density, peak_modifier):
		
		return vert_map.make_mountains(peak_density, peak_modifier)
		
	func activate(name, edge_list):
		chunk_name = name
		status = true
		edges = edge_list
		
	func get_linked_verts(vert):
		
		# print("chunk returning: ", vert_map.get_linked_verts(vert))
		
		return vert_map.get_linked_verts(vert)

class VertMap:
	
	var parent_chunk
	var verts = []
	
	func _init(parent):
		
		parent_chunk = parent
		
	func get_linked_verts(link_vert):
		
		# print("link_vert: ", link_vert)
		
		for vert in verts:
			if vert.point == link_vert:
				return vert.neighbors.duplicate()
				
	func make_mountains(peak_density, peak_modifier):
		
		print("VertMap.make_mountains")
		
		var new_peaks = [] 
		
		for vert in verts:
			var rand_gen = RandomNumberGenerator.new()
			var peak_chance = rand_gen.randi() % 100
			if peak_chance <= peak_density:
				vert.is_peak = true
				# new_peaks.append(vert.index)
				
		print("vertice number: ", len(verts))
		# print("new_peaks: ", new_peaks)
				
		var fill_inc = 1
		
		var step_one_tracker = []
		var step_peak
		
		for vert in verts:
			step_peak = false
			if not vert.is_peak:
				# print("not peak - neighbors: ", vert.neighbors)
				for neighbor in vert.neighbors:
					# print("neighbor.chunk: ", neighbor.chunk, "neighbor.index: ", neighbor.index)
					if parent_chunk.parent_map.terrain_map[neighbor.chunk[0]][neighbor.chunk[1]].vert_map.verts[neighbor.index].is_peak:
						vert.peak_steps.append([VertRef.new(neighbor.chunk, neighbor.index), 1])
						step_peak = true
						# print("step 1 vert")
			if step_peak:
				step_one_tracker.append(vert)
				
		print("step 1 verts: ", len(step_one_tracker))#, " | ", step_one_tracker)
						
		while fill_inc < parent_chunk.parent_map.size + 1:
			
			var step_tracker = []
			
			for vert in verts:
				step_peak = false
				if not vert.is_peak:
					# print("vert: ", vert.index, ", ", vert.point, ", # of neighbors: ", len(vert.neighbors))
					for neighbor in vert.neighbors:
						# print("neighbor: ", neighbor.index, ", ", neighbor.chunk)
						# print("neighbor peak steps: ", parent_chunk.parent_map.terrain_map[neighbor.chunk[0]][neighbor.chunk[1]].vert_map.verts[neighbor.index].peak_steps)
						for ref in parent_chunk.parent_map.terrain_map[neighbor.chunk[0]][neighbor.chunk[1]].vert_map.verts[neighbor.index].peak_steps:
							# print("ref[1]: ", ref[1], ", fill_inc: ", fill_inc)
							if ref[1] == fill_inc:
								# print("is equal")
								# print("peak steps: ", len(vert.peak_steps))
								if len(vert.peak_steps) > 0:
									pass
									# print("has peak steps")
									#for step in range(0, len(vert.peak_steps)):
										# print("step: ", vert.peak_steps[step])
										# print("step[0]: ", step[0].index, ", ", step[0].chunk, ", ref[0]: ", ref[0].index, ", ", ref[0].chunk)
										#if vert.peak_steps[step][0].chunk != ref[0].chunk or vert.peak_steps[step][0].index != ref[0].index:
											# print("bingo")
											# print("add step")
											#vert.peak_steps.append([VertRef.new(ref[0].chunk, ref[0].index), fill_inc + 1])
											#step_tracker.append(vert)
											#step_peak = true
								else:
									# print("no peak steps, add step")
									# print("bingo")
									vert.peak_steps.append([VertRef.new(ref[0].chunk, ref[0].index), fill_inc + 1])
									step_tracker.append(vert)
									step_peak = true
									
										
			# print("fill_inc: ", fill_inc)
			fill_inc += 1
			print("--- step ", fill_inc, " verts: ", len(step_tracker))#, step_tracker)
										
		var max_peak = parent_chunk.parent_map.size * peak_modifier
		
		print("max_peak: ", max_peak)
		
		for vert in verts:
			
			var new_z
			
			# print("vert.is_peak: ", vert.is_peak)
			
			if vert.is_peak:
				new_z = max_peak
			else:
				if len(vert.peak_steps) > 0:
					# print("vert.peak_steps: ", vert.peak_steps)
					var steps = 0
					for step in vert.peak_steps:
						# print("step: ", step, ", steps: ", steps)
						# steps += step[1]
						# var step_avg = steps / len(vert.peak_steps)
						# new_z = max_peak - (step_avg * step_avg)
						new_z = step[1] * peak_modifier
				else:
					# print("no steps")
					new_z = 0
					
					
			var new_vert = Vector3(vert.point[0], vert.point[1] + new_z, vert.point[2])
			#print("vert.point: ", vert.point, ", new_z: ", new_z, ", new_vert: ", new_vert)
			
			new_peaks.append(new_vert)
			vert.point = new_vert
			
		print("peaks created")
		# print("new peaks: ", new_peaks)
		return new_peaks
	
	func fill(vert_list, xinc, zinc, size ):
		
		print("VertMap.fill")
		print("parent: ", parent_chunk, " parent pos: ", parent_chunk.map_position)
		
		# print("vert_list: ", vert_list)
		
		var half_x = xinc / 2
		var half_z = zinc / 2
		var z_mod = int(size * 0.66)
		var xmax = (xinc * size) / 2
		var zmax = snapped(((zinc * (size + z_mod)) + half_z) / 2, 0.001)
		var zlim  = snapped(zmax - half_z, 0.001)
		var xmin = 0 - (half_x * size)
		var zmin = snapped(0 - zmax, 0.001)
		
		# print("vert_list: ", vert_list)
		print("zmin: ", zmin, ", zmax: ", zmax, ", xmin: ", xmin, " xmax: ", xmax, ", zlim: ", zlim, " zinc: ", zinc, ", half_z: ", half_z)
		
		# for fill_vert in range(0, len(vert_list)):
			
			# verts.append(Vert.new(fill_vert, vert_list[fill_vert]))
		
		for fill_vert in range(0, len(vert_list)):
			
			var new_vert = Vert.new(fill_vert, vert_list[fill_vert])
			# print("new_vert: ", new_vert.index, ", ", new_vert.point)
		
			var neighbors = parent_chunk.parent_map.get_edges(parent_chunk.map_position, true)
			# print("neighbors: ", neighbors)
			
			var nwest
			var north
			var neast
			var seast
			var south
			var swest
			
			# print("- x: ", vert_list[fill_vert][0])
			
			if vert_list[fill_vert][0] == xmin:
				# print("x = xmin (", xmin, ")")
				# print("left col - index: ", fill_vert, ", x: ", vert_list[fill_vert][0], ", z: ", snapped(vert_list[fill_vert][2], 0.001))
				# x = xmin, z = -3.893 (zmin = 
				if snapped(vert_list[fill_vert][2], 0.001) < zlim - 0.005:
					north = Vector2(vert_list[fill_vert][0], snapped(vert_list[fill_vert][2] + zinc, 0.001))
					#print("north: ", north, ", z: ", vert_list[fill_vert][1], ", zinc: ", zinc)
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(north, vert_list, fill_vert, "north1")))
					# print("0")
					# index: 6
					
				neast = Vector2(vert_list[fill_vert][0] + half_x, snapped(vert_list[fill_vert][2] + half_z, 0.001))
				new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(neast, vert_list, fill_vert, "neast1")))
				# print("1")
				# index: 3
				
				if snapped(vert_list[fill_vert][2], 0.001) > zmin:
					seast = Vector2(vert_list[fill_vert][0] + half_x, snapped(vert_list[fill_vert][2] - half_z, 0.001))
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(seast, vert_list, fill_vert, "seast1")))
					# print("2")
					
					south = Vector2(vert_list[fill_vert][0], snapped(vert_list[fill_vert][2] - zinc, 0.001))
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(south, vert_list, fill_vert, "south1")))
					# print("3")
					
				if neighbors[2]:					
					# print("neighbors: ", neighbors)
					# print("position: ", Vector2(neighbors[2][0], neighbors[2][1]), ", vert: ", vert_list[fill_vert])
					var links = parent_chunk.parent_map.get_linked_verts(Vector2(neighbors[2][0], neighbors[2][1]), vert_list[fill_vert])
					if links:
						#print("links: ", links)
						for link in links:
							new_vert.neighbors.append(link)
					
				if snapped(vert_list[fill_vert][2], 0.001) == zmin and neighbors[1]:
					var links = parent_chunk.parent_map.get_linked_verts(Vector2(neighbors[1][0], neighbors[1][1]), vert_list[fill_vert])
					if links:
						#print("links: ", links)
						for link in links:
							new_vert.neighbors.append(link)
					
				if vert_list[fill_vert][0] == xmin and neighbors[0]:
					var links = parent_chunk.parent_map.get_linked_verts(Vector2(neighbors[0][0], neighbors[0][1]), vert_list[fill_vert])
					if links:
						#print("links: ", links)
						for link in links:
							new_vert.neighbors.append(link)				
					
			elif vert_list[fill_vert][0] > xmin and vert_list[fill_vert][0] < xmax:
				# print("middle cols - index: ", fill_vert, ", x: ", vert_list[fill_vert][0], ", z: ", snapped(vert_list[fill_vert][2], 0.001))
				# print("x = ", vert_list[fill_vert][0],", y = ", vert_list[fill_vert][1])
				if snapped(vert_list[fill_vert][2], 0.001) < zlim - 0.005:
					north = Vector2(vert_list[fill_vert][0], snapped(vert_list[fill_vert][2] + zinc, 0.001))
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(north, vert_list, fill_vert, "north2")))
					# print("4 - north: ", north)
					
				if snapped(vert_list[fill_vert][2], 0.001) < zlim + half_z - 0.005:
					neast = Vector2(vert_list[fill_vert][0] + half_x, snapped(vert_list[fill_vert][2] + half_z, 0.001))
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(neast, vert_list, fill_vert, "neast2")))
					# print("5 - neast: ", neast)
					
					nwest = Vector2(vert_list[fill_vert][0] - half_x, snapped(vert_list[fill_vert][2] + half_z, 0.001))
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(nwest, vert_list, fill_vert, "nwest2")))
					# print("6 - nwest: ", nwest)
				
				if snapped(vert_list[fill_vert][2], 0.001) > zmin:
					seast = Vector2(vert_list[fill_vert][0] + half_x, snapped(vert_list[fill_vert][2] - half_z, 0.001))
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(seast, vert_list, fill_vert, "seast2")))
					# print("7 - seast: ", seast)
					
					swest = Vector2(vert_list[fill_vert][0] - half_x, snapped(vert_list[fill_vert][2] - half_z, 0.001))
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(swest, vert_list, fill_vert, "swest2")))
					# print("8 - swest: ", swest)
					
				# print("z: ", vert_list[fill_vert][1], ", half_z: ", half_z)
					
				if snapped(vert_list[fill_vert][2], 0.001) > zmin + half_z + 0.005:
					# print("z > half_z")
					south = Vector2(vert_list[fill_vert][0], snapped(vert_list[fill_vert][2] - zinc, 0.001))
					# print("south: ", south)
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(south, vert_list, fill_vert, "south2")))
					# print("9 - south: ", south)
					
				if snapped(vert_list[fill_vert][2], 0.001) >= zlim and neighbors[0]:
					var links = parent_chunk.parent_map.get_linked_verts(Vector2(neighbors[0][0], neighbors[0][1]), vert_list[fill_vert])
					if links:
						#print("links: ", links)
						for link in links:
							new_vert.neighbors.append(link)
					
				if snapped(vert_list[fill_vert][2], 0.001) <= half_z and neighbors[1]:
					var links = parent_chunk.parent_map.get_linked_verts(Vector2(neighbors[1][0], neighbors[1][1]), vert_list[fill_vert])
					if links:
						#print("links: ", links)
						for link in links:
							new_vert.neighbors.append(link)
				
			elif vert_list[fill_vert][0] == xmax:
				#print("right col - index: ", fill_vert, ", x: ", vert_list[fill_vert][0], ", z: ", snapped(vert_list[fill_vert][2], 0.001))
				if snapped(vert_list[fill_vert][2], 0.001) < zlim - 0.005:
					#print(vert_list[fill_vert][2], " < ", zlim)
					north = Vector2(vert_list[fill_vert][0], snapped(vert_list[fill_vert][2] + zinc, 0.001))
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(north, vert_list, fill_vert, "north3")))
					#print("10 - north: ", north)
					
				nwest = Vector2(vert_list[fill_vert][0] - half_x, snapped(vert_list[fill_vert][2] + half_z, 0.001))
				new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(nwest, vert_list, fill_vert, "nwest3")))
				#print("11 - nwest: ", nwest)
				
				if snapped(vert_list[fill_vert][2], 0.001) > zmin:
					# print(vert_list[fill_vert][2], " > ", zmin)
					swest = Vector2(vert_list[fill_vert][0] - half_x, snapped(vert_list[fill_vert][2] - half_z, 0.001))
					# print("swest: ", swest)
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(swest, vert_list, fill_vert, "swest3")))
					#print("12 - swest: ", swest)
					
					south = Vector2(vert_list[fill_vert][0], snapped(vert_list[fill_vert][2] - zinc, 0.001))
					new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_index(south, vert_list, fill_vert, "south3")))
					#print("13 - south: ", south)
					
				if neighbors[3]:
					var links = parent_chunk.parent_map.get_linked_verts(Vector2(neighbors[3][0], neighbors[3][1]), vert_list[fill_vert])
					if links:
						#print("links: ", links)
						for link in links:
							new_vert.neighbors.append(link)
					
				if snapped(vert_list[fill_vert][2], 0.001) == zmin and neighbors[1]:
					var links = parent_chunk.parent_map.get_linked_verts(Vector2(neighbors[1][0], neighbors[1][1]), vert_list[fill_vert])
					if links:
						#print("links: ", links)
						for link in links:
							new_vert.neighbors.append(link)
					
				if snapped(vert_list[fill_vert][0], 0.001) == xmin and neighbors[0]:
					var links = parent_chunk.parent_map.get_linked_verts(Vector2(neighbors[0][0], neighbors[0][1]), vert_list[fill_vert])
					if links:
						#print("links: ", links)
						for link in links:
							new_vert.neighbors.append(link)
						
			# print("new_vert: ", new_vert.index, ", ", new_vert.point)
			# for neighbor in new_vert.neighbors:
				# print("neighbor.index: ", neighbor.index)
			verts.append(new_vert)
			# print("dirs: ", len(new_vert.neighbors), ", nwest: ", nwest, ", north: ", north, ", neast: ", neast, ", seast: ", seast, ", south: ", south, ", swest: ", swest)
			# print("new_vert neighbors: ", new_vert.neighbors)
						
	func get_index(v_point, v_list, index, direction=''):
		
		# print("get_index - v_point: ", v_point[0], ", ", v_point[1])
				
		for i in range(0, len(v_list)):
			if v_list[i][0] == v_point[0]:
				# print("index: ", index, ", v_list: ", v_list[i][0],", ", snapped(v_list[i][2], 0.001), ", v_point: ", v_point[0], ", ", snapped(v_point[1], 0.001))
				if snapped(v_list[i][2], 0.001) < snapped(v_point[1], 0.001) + 0.005 and snapped(v_list[i][2], 0.001) > snapped(v_point[1], 0.001) - 0.005:
					# print("index matched - ", direction, ": ", i)
					return i
				# else:
					# print("null return - x - ", direction, " - vpoint: ", v_point, " - loops: ", i)
					# pass
			# else:
				# print("null return - z - ", direction, " - vpoint: ", v_point, " - loops: ", i)
				# pass
		print("null return - ", direction, ", ", v_point[0], " - ", snapped(v_point[1], 0.001))
