extends Node3D

var xr_interface: XRInterface

func _ready():
	if Global.Gltf_PackedScene:
		Global.gltf_scene_node = Global.Gltf_PackedScene.instantiate()
		add_child(Global.gltf_scene_node)
		if Global.Model_Scalar >= 0:
			Global.gltf_scene_node.scale.x = 1 + 1*Global.Model_Scalar
			Global.gltf_scene_node.scale.y = 1 + 1*Global.Model_Scalar
			Global.gltf_scene_node.scale.z = 1 + 1*Global.Model_Scalar
		elif Global.Model_Scalar < 0:
			var value = abs(Global.Model_Scalar)
			Global.gltf_scene_node.scale.x = 1/value
			Global.gltf_scene_node.scale.y = 1/value
			Global.gltf_scene_node.scale.z = 1/value
			Global.gltf_scene_node.position = Global.Model_Pos
	else:
			print("VR mode started, but no model is detected")

	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully")

		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized, please check if your headset is connected")
		
