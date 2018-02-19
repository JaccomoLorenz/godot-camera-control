# Licensed under the MIT License.
# Copyright (c) 2018 Jaccomo Lorenz (Maujoe)

extends Control

const GUI_SIZE = Vector2(200, 0)
const MAX_SPEED = 50
var camera
var shortcut
var node_list
var privot

func _init(camera, shortcut):
	self.camera = camera
	self.shortcut = shortcut

func _ready():
	if camera.enabled:
		set_process_input(true)
		# Create Gui

		var container = VBoxContainer.new()
		container.set_begin(Vector2(10, 10))
		container.set_custom_minimum_size(GUI_SIZE)

		var lbl_mouse = Label.new()
		lbl_mouse.set_text("Mousemode")

		var mouse = OptionButton.new()
		mouse.add_item("Visible")
		mouse.add_item("Hidden")
		mouse.add_item("Captured")
		mouse.add_item("Confined")
		mouse.select(camera.mouse_mode)
		mouse.connect("item_selected",self,"_on_opt_mouse_item_selected")

		# Mouselook
		var mouselook = CheckButton.new()
		mouselook.set_text("Mouselook")
		mouselook.set_toggle_mode(true)
		mouselook.set_pressed(camera.mouselook)
		mouselook.connect("toggled",self,"_on_btn_mouselook_toggled")

		var lbl_sensitivity = Label.new()
		lbl_sensitivity.set_text("Sensitivity")

		var sensitivity = HScrollBar.new()
		sensitivity.set_max(1)
		sensitivity.set_value(camera.sensitivity)
		sensitivity.connect("value_changed",self,"_on_hsb_sensitivity_value_changed")

		var lbl_smoothless = Label.new()
		lbl_smoothless.set_text("Smoothness")

		var smoothness = HScrollBar.new()
		smoothness.set_max(0.999)
		smoothness.set_min(0.5)
		smoothness.set_value(camera.smoothness)
		smoothness.connect("value_changed",self,"_on_hsb_smoothness_value_changed")

		var lbl_privot = Label.new()
		lbl_privot.set_text("Privot")

		privot = OptionButton.new()
		privot.set_text("Privot")
		_update_privots(privot)
		privot.connect("item_selected",self,"_on_opt_privot_item_selected")
		privot.connect("pressed",self,"_on_opt_privot_pressed")

		var btn_rot_privot = CheckButton.new()
		btn_rot_privot.set_text("Rotate Privot")
		btn_rot_privot.set_toggle_mode(true)
		btn_rot_privot.set_pressed(camera.rotate_privot)
		btn_rot_privot.connect("toggled",self,"_on_btn_rot_privot_toggled")

		var lbl_distance = Label.new()
		lbl_distance.set_text("Distance")

		var distance = SpinBox.new()
		distance.set_value(camera.distance)
		distance.connect("value_changed",self,"_on_box_distance_value_changed")

		var lbl_yaw = Label.new()
		lbl_yaw.set_text("Yaw Limit")

		var yaw = SpinBox.new()
		yaw.set_max(360)
		yaw.set_value(camera.yaw_limit)
		yaw.connect("value_changed",self,"_on_box_yaw_value_changed")

		var lbl_pitch = Label.new()
		lbl_pitch.set_text("Pitch Limit")

		var pitch = SpinBox.new()
		pitch.set_max(360)
		pitch.set_value(camera.pitch_limit)
		pitch.connect("value_changed",self,"_on_box_pitch_value_changed")

		var collisions = CheckButton.new()
		collisions.set_text("Collisions")
		collisions.set_toggle_mode(true)
		collisions.set_pressed(camera.collisions)
		collisions.connect("toggled",self,"_on_btn_collisions_toggled")

		# Movement
		var lbl_movement = Label.new()
		lbl_movement.set_text("Movement")

		var movement = CheckButton.new()
		movement.set_pressed(camera.movement)
		movement.connect("toggled",self,"_on_btn_movement_toggled")

		var lbl_speed = Label.new()
		lbl_speed.set_text("Speed")

		var speed = HScrollBar.new()
		speed.set_max(MAX_SPEED)
		speed.set_value(camera.speed)
		speed.connect("value_changed",self,"_on_hsb_speed_value_changed")

		add_child(container)
		container.add_child(lbl_mouse)
		container.add_child(mouse)
		container.add_child(mouselook)
		container.add_child(lbl_sensitivity)
		container.add_child(sensitivity)
		container.add_child(lbl_smoothless)
		container.add_child(smoothness)
		container.add_child(lbl_privot)
		container.add_child(privot)
		container.add_child(btn_rot_privot)
		container.add_child(lbl_distance)
		container.add_child(distance)
		container.add_child(lbl_yaw)
		container.add_child(yaw)
		container.add_child(lbl_pitch)
		container.add_child(pitch)
		container.add_child(collisions)
		container.add_child(lbl_movement)
		container.add_child(movement)
		container.add_child(lbl_speed)
		container.add_child(speed)
		self.hide()
	else:
		set_process_input(false)

func _input(event):
	if event.is_action_pressed(shortcut):
		if camera.enabled:
			camera.enabled = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			self.show()
		else:
			camera.enabled = true
			self.hide()

func _update_privots(privot):
	privot.clear()
	privot.add_item("None")
	node_list = _get_spatials_recusiv(get_tree().get_root(), [get_name(), camera.get_name()])

	var size = node_list.size()
	for i in range(0, size):
		var node = node_list[i]
		privot.add_item(node.get_name())
		if node == camera.privot:
			privot.select(i+1)

	if not camera.privot:
		privot.select(0)


func _get_spatials_recusiv(node, exceptions=[]):
	var list = []
	for child in node.get_children():
		if not child.get_name() in exceptions:
			if child is Spatial:
				list.append(child)
			if not child.get_children().empty():
				for subchild in _get_spatials_recusiv(child, exceptions):
					list.append(subchild)
	return list

func _on_opt_mouse_item_selected(id):
	camera.mouse_mode = id

func _on_btn_mouselook_toggled(pressed):
	camera.mouselook = pressed

func _on_hsb_sensitivity_value_changed(value):
	camera.sensitivity = value

func _on_hsb_smoothness_value_changed(value):
	camera.smoothness = value

func _on_opt_privot_pressed():
	_update_privots(privot)

func _on_opt_privot_item_selected(id):
	if id > 0:
		camera.privot = node_list[id-1]
	else:
		camera.privot = null
	privot.select(id)

func _on_btn_rot_privot_toggled(pressed):
	camera.rotate_privot = pressed

func _on_box_distance_value_changed(value):
	camera.distance = value

func _on_box_yaw_value_changed(value):
	camera.yaw_limit = value

func _on_box_pitch_value_changed(value):
	camera.pitch_limit = value

func _on_btn_collisions_toggled(pressed):
	camera.collisions = pressed

func _on_btn_movement_toggled(pressed):
	camera.movement = pressed

func _on_hsb_speed_value_changed(value):
	camera.speed = value
