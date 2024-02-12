extends TerrainDepressions
class_name TerrainDepression

@export var depth = -10.0
@export var width = 10.0
@export var origin:Vector3 = Vector3(0, 0, 0)

# apply_curve makes simple smooth bowl shape

func apply_curve(point):
	
	var distance = point.distance_to(origin)	
	
	var e = 2.718282
	
	var neg_one = 1 - 2
	var curve = depth * (e**(neg_one * (distance**2) / (2 * (width**2))))
	
	return curve
