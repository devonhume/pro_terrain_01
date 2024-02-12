extends TerrainFeature
class_name TerrainDepressions

enum DepressionTypes {Single, Cluster, Ring, Series}

@export var build_mode:BuildMode = BuildMode.Additive
@export var type:DepressionTypes = DepressionTypes.Single
