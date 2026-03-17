extends CharacterBody3D

@export var move_speed: float = 3.0
@export var rotation_speed: float = 2.0
@onready var xr_origin: XROrigin3D = $XROrigin3D
@onready var camera: XRCamera3D = $XROrigin3D/XRCamera3D
@onready var left_controller: XRController3D = $XROrigin3D/LeftHand
@onready var right_controller: XRController3D = $XROrigin3D/RightHand
@onready var debug_textbox: Label3D = $XROrigin3D/RightHand/DebugLabel
@onready var vr_menu: Control = $XROrigin3D/VR_Menu_Parent/VR_Menu_Viewport/VR_Menu
@onready var vr_menu_parent: Sprite3D = $XROrigin3D/VR_Menu_Parent
@onready var menu_button_pressed: bool = false


func _ready():
	debug_textbox.text = "Movement Speed " + str(move_speed)

func _physics_process(delta: float):
	if left_controller.get_tracker_hand() != XRPositionalTracker.TRACKER_HAND_LEFT and right_controller.get_tracker_hand() != XRPositionalTracker.TRACKER_HAND_RIGHT:
		return


	# probably need to replace speed increase/decrease with a log or exponent
	if left_controller.is_button_pressed("ax_button"): # Find a way to change to menu_button/detect when menu_button is already assigned by vr client
		if not menu_button_pressed:
			if OS.is_debug_build():
				print("[Debug] ", "VR Menu Button pressed")
			vr_menu_parent.visible = not vr_menu_parent.visible
			$XROrigin3D/LeftHand/RaycastLine.visible = not $XROrigin3D/LeftHand/RaycastLine.visible
			$XROrigin3D/RightHand/RaycastLine.visible = not $XROrigin3D/RightHand/RaycastLine.visible
			menu_button_pressed = true
	else:
		menu_button_pressed = false
	if not vr_menu_parent.visible:
		if right_controller.get_input("ax_button") and right_controller.get_input("by_button"):
			pass
		elif right_controller.get_input("ax_button") and move_speed > 0:
			move_speed -= 0.1
			debug_textbox.text = "Movement Speed " + str(move_speed)
		elif right_controller.get_input("by_button"):
			move_speed += 0.1
			debug_textbox.text = "Movement Speed " + str(move_speed)

		var input_joystick_L: Vector2 = left_controller.get_vector2("primary")
		var input_joystick_R: Vector2 = right_controller.get_vector2("primary")

		# Threshold for movement
		if input_joystick_L.length() < 0.1:
			input_joystick_L = Vector2.ZERO
		if input_joystick_R.length() < 0.1:
			input_joystick_R = Vector2.ZERO

	# TODO: change how movement is being handled. I don't like the variable names

		var forward: Vector3 = -camera.global_transform.basis.z
		forward.y = 0
		forward = forward.normalized()

		var right: Vector3 = camera.global_transform.basis.x
		right.y = 0
		right = right.normalized()
		
		var up: Vector3 = camera.global_transform.basis.y
		up.x = 0
		up = up.normalized()

		var move_dir: Vector3 = (forward * input_joystick_L.y + right * input_joystick_L.x + up * input_joystick_R.y)

		velocity.x = move_dir.x * move_speed
		velocity.y = move_dir.y * (move_speed/2)
		velocity.z = move_dir.z * move_speed
		
		var rotate_amount = -input_joystick_R.x * rotation_speed * delta
		xr_origin.rotate_y(rotate_amount)


		move_and_slide()
	elif (left_controller.get_input("trigger_click") and $XROrigin3D/LeftHand/RayLeftHand.is_colliding()) \
	or (right_controller.get_input("trigger_click") and $XROrigin3D/RightHand/RayRightHand.is_colliding()):
		var RayLeftCollider: Object = $XROrigin3D/LeftHand/RayLeftHand.get_collider()
		var RayRightCollider: Object = $XROrigin3D/RightHand/RayRightHand.get_collider()
		var RayLeftCord: Vector3 = $XROrigin3D/LeftHand/RayLeftHand.get_collision_point()
		var RayRightCord: Vector3 = $XROrigin3D/RightHand/RayRightHand.get_collision_point()
		var collision_size = $XROrigin3D/VR_Menu_Parent/VR_Menu_Area3D/VR_Menu_Collision.shape.size
		if RayLeftCollider == $XROrigin3D/VR_Menu_Parent/VR_Menu_Area3D:
			var left_event = InputEventMouseButton.new()
			RayLeftCord = $XROrigin3D/VR_Menu_Parent/VR_Menu_Area3D/VR_Menu_Collision.to_local(RayLeftCord)
			left_event.position = Vector2((RayLeftCord.x/collision_size.x +0.5) * 1280, \
			(-RayLeftCord.y/ collision_size.y+0.5)*720)
			left_event.global_position = left_event.position
			left_event.button_index = MOUSE_BUTTON_LEFT
			left_event.pressed = true
			$XROrigin3D/VR_Menu_Parent/VR_Menu_Viewport.push_input(left_event)
			left_event.pressed = false
			$XROrigin3D/VR_Menu_Parent/VR_Menu_Viewport.push_input(left_event)
		if RayRightCollider == $XROrigin3D/VR_Menu_Parent/VR_Menu_Area3D:
			var right_event = InputEventMouseButton.new()
			RayRightCord = $XROrigin3D/VR_Menu_Parent/VR_Menu_Area3D/VR_Menu_Collision.to_local(RayRightCord)
			right_event.position = Vector2((RayRightCord.x/collision_size.x +0.5) * 1280, \
			(-RayRightCord.y/ collision_size.y+0.5)*720)
			right_event.global_position = right_event.position
			right_event.button_index = MOUSE_BUTTON_LEFT
			right_event.pressed = true
			$XROrigin3D/VR_Menu_Parent/VR_Menu_Viewport.push_input(right_event)
			right_event.pressed = false
			$XROrigin3D/VR_Menu_Parent/VR_Menu_Viewport.push_input(right_event)


func _reset_player_pos():
	print("Player postion has been reset")
	position = Vector3.ZERO
	$XROrigin3D.position = Vector3.ZERO


func _on_button_exit_vr_pressed():
	# This is broken
	print("Program exit has been called")
	get_viewport().use_xr = false
	await get_tree().process_frame
	get_tree().quit()
	#get_tree().change_scene_to_file.call_deferred("res://Scenes/File_Importer_Menu/importer_menu.tscn")
