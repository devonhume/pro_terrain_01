extends TerrainMountains
class_name TerrainMountain

@export var height = 20.0
@export var width = 10.0
@export var origin:Vector3 = Vector3(0, 0, 0)

# apply_curve make simple smooth mountain shape

func apply_curve(point):
	
	var distance = point.distance_to(origin)	
	
	var e = 2.718282
	
	var neg_one = 1 - 2
	var curve = height * (e**(neg_one * (distance**2) / (2 * (width**2))))
	
	return curve
