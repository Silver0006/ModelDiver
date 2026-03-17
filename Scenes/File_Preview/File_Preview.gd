extends Node3D

func _ready():
	if Global.Gltf_PackedScene:
		Global.gltf_scene_node = Global.Gltf_PackedScene.instantiate()
		add_child(Global.gltf_scene_node)
