extends Node
class_name VertMap
#class VertMap:
	
var parent_chunk
var verts = []
	
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
				new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_vert_index(north, vert_list, fill_vert, "north1")))
				
			neast = Vector2(vert_list[fill_vert][0] + half_x, snapped(vert_list[fill_vert][2] + half_z, 0.001))
			new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_vert_index(neast, vert_list, fill_vert, "neast1")))
			
			if snapped(vert_list[fill_vert][2], 0.001) > zmin:
				seast = Vector2(vert_list[fill_vert][0] + half_x, snapped(vert_list[fill_vert][2] - half_z, 0.001))
				new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_vert_index(seast, vert_list, fill_vert, "seast1")))
				
				south = Vector2(vert_list[fill_vert][0], snapped(vert_list[fill_vert][2] - zinc, 0.001))
				new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_vert_index(south, vert_list, fill_vert, "south1")))
				
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
				new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_vert_index(north, vert_list, fill_vert, "north2")))
				
			if snapped(vert_list[fill_vert][2], 0.001) < zlim + half_z - 0.005:
				neast = Vector2(vert_list[fill_vert][0] + half_x, snapped(vert_list[fill_vert][2] + half_z, 0.001))
				new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_vert_index(neast, vert_list, fill_vert, "neast2")))
				
				nwest = Vector2(vert_list[fill_vert][0] - half_x, snapped(vert_list[fill_vert][2] + half_z, 0.001))
				new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_vert_index(nwest, vert_list, fill_vert, "nwest2")))
			
			if snapped(vert_list[fill_vert][2], 0.001) > zmin:
				seast = Vector2(vert_list[fill_vert][0] + half_x, snapped(vert_list[fill_vert][2] - half_z, 0.001))
				new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_vert_index(seast, vert_list, fill_vert, "seast2")))
				
				swest = Vector2(vert_list[fill_vert][0] - half_x, snapped(vert_list[fill_vert][2] - half_z, 0.001))
				new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_vert_index(swest, vert_list, fill_vert, "swest2")))
				
			if snapped(vert_list[fill_vert][2], 0.001) > zmin + half_z + 0.005:
				south = Vector2(vert_list[fill_vert][0], snapped(vert_list[fill_vert][2] - zinc, 0.001))
				new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_vert_index(south, vert_list, fill_vert, "south2")))
				
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
				new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_vert_index(north, vert_list, fill_vert, "north3")))
				
			nwest = Vector2(vert_list[fill_vert][0] - half_x, snapped(vert_list[fill_vert][2] + half_z, 0.001))
			new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_vert_index(nwest, vert_list, fill_vert, "nwest3")))
			
			if snapped(vert_list[fill_vert][2], 0.001) > zmin:
				swest = Vector2(vert_list[fill_vert][0] - half_x, snapped(vert_list[fill_vert][2] - half_z, 0.001))
				new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_vert_index(swest, vert_list, fill_vert, "swest3")))
				
				south = Vector2(vert_list[fill_vert][0], snapped(vert_list[fill_vert][2] - zinc, 0.001))
				new_vert.neighbors.append(VertRef.new(parent_chunk.map_position, get_vert_index(south, vert_list, fill_vert, "south3")))
				
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
					
func get_vert_index(v_point, v_list, index, direction=''):
			
	for i in range(0, len(v_list)):
		if v_list[i][0] == v_point[0]:
			if snapped(v_list[i][2], 0.001) < snapped(v_point[1], 0.001) + 0.005 and snapped(v_list[i][2], 0.001) > snapped(v_point[1], 0.001) - 0.005:
				return i

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

