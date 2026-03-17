extends Control

var ModelFilePrompt: FileDialog
var Label_ModelFile: Label
var Label_ConfigFile: Label
var Preview_Window: Window

func _ready():
	get_viewport().use_xr = false
	Label_ModelFile = get_node("Label_ModelFile")
	Label_ConfigFile = get_node("Label_ConfigFile")

func _on_pressed_startVR():
	if OS.is_debug_build():
		print("[Debug] ", "Start VR Button pressed")
	get_tree().change_scene_to_file("res://Scenes/VR_View/VR_View.tscn")

func _on_pressed_FilePrompt(button_type: String):
	if ModelFilePrompt:
		ModelFilePrompt.queue_free()
		ModelFilePrompt = null
	ModelFilePrompt = FileDialog.new()
	if button_type == "Load3DModel":
		ModelFilePrompt.filters = PackedStringArray(["*.glb, *.gltf"])
		ModelFilePrompt.access = FileDialog.ACCESS_FILESYSTEM
		ModelFilePrompt.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		add_child(ModelFilePrompt)
		ModelFilePrompt.file_selected.connect(_on_3DModel_selected)
		ModelFilePrompt.popup_centered()
	elif button_type == "ConfigLoad":
		ModelFilePrompt.filters = PackedStringArray(["*.json, *.bin"])
		ModelFilePrompt.access = FileDialog.ACCESS_FILESYSTEM
		ModelFilePrompt.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		add_child(ModelFilePrompt)
		ModelFilePrompt.file_selected.connect(_on_ConfigLoad_selected)
		ModelFilePrompt.popup_centered()
	elif button_type == "ConfigSave":
		ModelFilePrompt.filters = PackedStringArray(["*.json, *.bin"])
		ModelFilePrompt.access = FileDialog.ACCESS_FILESYSTEM
		ModelFilePrompt.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		add_child(ModelFilePrompt)
		ModelFilePrompt.file_selected.connect(_on_ConfigSave_selected)
		ModelFilePrompt.popup_centered()

func _on_3DModel_selected(path: String):
	Label_ModelFile.text = "Current File: Loading"
	var importer = GLTFDocument.new()
	var state = GLTFState.new()
	if importer.append_from_file(path, state) != OK:
		push_error("Failed to load GLTF/GLB")
		Label_ModelFile.text = "Current File: Failed to load"
		return
	var scene = importer.generate_scene(state)
	var packed = PackedScene.new()
	packed.pack(scene)
	Global.Gltf_PackedScene = packed
	Global.ModelFile_path = path
	Label_ModelFile.text = "Current File: " + path
	
func _on_ConfigSave_selected(path: String):
	var file := FileAccess.open(path, FileAccess.WRITE)
	if path.contains(".json"):
		var data = {
			"Version": ProjectSettings.get_setting("application/config/version"),
			"ModelFile_path": Global.ModelFile_path,
			"Model_Scalar": Global.Model_Scalar,
			"Model_Pos": Global.Model_Pos
		}
		file.store_string(JSON.stringify(data))
		file.close()
	else:
		file.store_8(Global.ConfigSave_Version)
		file.store_pascal_string(ProjectSettings.get_setting("application/config/version"))
		file.store_pascal_string(Global.ModelFile_path)
		file.store_float(Global.Model_Scalar)
		file.store_float(Global.Model_Pos[0])
		file.store_float(Global.Model_Pos[1])
		file.store_float(Global.Model_Pos[2])
		file.close()
	
func _on_ConfigLoad_selected(path: String): # Need to add version checking in next version
	Label_ConfigFile.text = "Config File: " + path
	var file := FileAccess.open(path, FileAccess.READ)
	if path.contains(".json"):
		var data = file.get_as_text()
		data = JSON.parse_string(data)
		if data == null: 
			push_error("Failed to parse JSON: %s" % data.error_string)
			return
		for key in data:
			match key:
				"ModelFile_path":
					Global.ModelFile_path = data[key]
				"Model_Scalar":
					Global.Model_Scalar = data[key]
				"Model_Pos":
					var v = data[key]
					v = v.remove_chars("() ")
					v = v.split(",")
					Global.Model_Pos = Vector3(float(v[0]),float(v[1]),float(v[2]))
		file.close()
		_on_3DModel_selected(Global.ModelFile_path)
		
	else:
		file.get_8() # Skipping over config version
		file.get_pascal_string() # Skipping over program version
		Global.ModelFile_path = file.get_pascal_string()
		Global.Model_Scalar = file.get_float()
		Global.Model_Pos = Vector3(file.get_float(), file.get_float(), file.get_float())
		file.close()
		_on_3DModel_selected(Global.ModelFile_path)
	
func _on_pressed_preview():
	Preview_Window = Window.new()
	Preview_Window.size = Vector2i(1280, 720)
	Preview_Window.position = Vector2i(200, 200)
	Preview_Window.title = "Model Previewer"
	var scene = load("res://Scenes/File_Preview/File_Preview.tscn").instantiate() 
	Preview_Window.add_child(scene)
	Preview_Window.close_requested.connect(_on_preview_closed)
	get_tree().root.add_child(Preview_Window)
	Preview_Window.show()

func _on_preview_closed():
	if Preview_Window:
		Preview_Window.queue_free()
		Preview_Window = null
	
		
