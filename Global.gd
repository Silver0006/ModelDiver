extends Node

const ConfigSave_Version: int = 1
var ValidConfig_Version: Vector2 = Vector2(1,1)
var ModelFile_path: String
var ConfigFile_path: String
var Model_Scalar: float = 1.0
var Model_Pos: Vector3 = Vector3(0,0,0)
var Gltf_PackedScene: PackedScene = null
var gltf_scene_node: Node

# Create debug print function
