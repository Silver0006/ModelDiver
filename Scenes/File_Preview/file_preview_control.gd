extends Control

@onready var preview_camera_node: Camera3D = $"../../Camera3D"
@onready var scalar_node: SpinBox = $"Label_ModelScalar/SpinBox_ModelScalar"
@onready var pos_nodes: Array[SpinBox] = [$"Label_xyz/SpinBox_position_x",$"Label_xyz/SpinBox_position_y",$"Label_xyz/SpinBox_position_z"]

func _ready():
	await get_tree().process_frame
	scalar_node.value = Global.Model_Scalar
	pos_nodes[0].value = Global.Model_Pos.x
	pos_nodes[1].value = Global.Model_Pos.y
	pos_nodes[2].value = Global.Model_Pos.z

func _camera_height_value_changed(value: float):
	preview_camera_node.position.y = value

func _on_model_scalar_value_changed(value: float):
	Global.Model_Scalar = value
	if Global.gltf_scene_node != null:
		if value >= 0:
			Global.gltf_scene_node.scale.x = 1 + 1*value
			Global.gltf_scene_node.scale.y = 1 + 1*value
			Global.gltf_scene_node.scale.z = 1 + 1*value
		else:
			value = abs(value)
			Global.gltf_scene_node.scale.x = 1/value
			Global.gltf_scene_node.scale.y = 1/value
			Global.gltf_scene_node.scale.z = 1/value

func _on_position_x_value_changed(value: float):
	Global.Model_Pos.x = value
	Global.gltf_scene_node.position.x = value

func _on_position_y_value_changed(value: float):
	Global.Model_Pos.y = value
	Global.gltf_scene_node.position.y = value

func _on_position_z_value_changed(value: float):
	Global.Model_Pos.z = value
	Global.gltf_scene_node.position.z = value
