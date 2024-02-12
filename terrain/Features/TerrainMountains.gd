extends TerrainFeature
class_name TerrainMountains

enum MountTypes {Single, Cluster, Crater, Series}

@export var build_mode:BuildMode = BuildMode.Additive
@export var type:MountTypes = MountTypes.Single


