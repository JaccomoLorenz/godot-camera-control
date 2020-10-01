# Licensed under the MIT License.
# Copyright (c) 2018-2020 Jaccomo Lorenz (Maujoe)

extends Spatial

# User settings:
# General settings
export var enabled = true setget set_enabled

# See https://docs.godotengine.org/en/latest/classes/class_input.html?highlight=Input#enumerations
export(int, "Visible", "Hidden", "Captured, Confined") var mouse_mode = Input.MOUSE_MODE_CAPTURED

enum Freelook_Modes {MOUSE, INPUT_ACTION, MOUSE_AND_INPUT_ACTION}

# Freelook settings
export var freelook = true
export (Freelook_Modes) var freelook_mode = 2
export (float, 0.0, 1.0) var sensitivity = 0.5
export (float, 0.0, 0.999, 0.001) var smoothness = 0.5 setget set_smoothness
export (int, 0, 360) var yaw_limit = 360
export (int, 0, 360) var pitch_limit = 360

# Pivot Settings
export(NodePath) var privot setget set_privot
export var distance = 5.0 setget set_distance
export var rotate_privot = false
export var collisions = true setget set_collisions
export(float) var collision_buffer = 0.05 #Offsets the camera closer to privot to prevent clipping of camera through geometry at odd angles

# Movement settings
export var movement = true
export (float, 0.0, 1.0) var acceleration = 1.0
export (float, 0.0, 0.0, 1.0) var deceleration = 0.1
export var max_speed = Vector3(1.0, 1.0, 1.0)
export var local = true

# Input Actions
export var rotate_left_action = ""
export var rotate_right_action = ""
export var rotate_up_action = ""
export var rotate_down_action = ""
export var forward_action = "ui_up"
export var backward_action = "ui_down"
export var left_action = "ui_left"
export var right_action = "ui_right"
export var up_action = "ui_page_up"
export var down_action = "ui_page_down"
export var trigger_action = ""
export var zoom_in_action = ""
export var zoom_out_action = ""

#Zoom settings
export(float, 0.0, 1.0) var zoom_min = 0.25 setget set_zoom_min #Percentage of total distance to be used as minimum distance to maintain
export(float, 0.0, 1.0) var zoom_percent = 0.0 setget set_zoom #Percentage value of Current Zoom Level (1.0 is completely zoomed in)
#Note: This can be smaller than zoom_min its the percent of the available range of distance.
export(float, 0.0, 1.0) var zoom_step = 0.01 setget set_zoom_step #On each event how much to change zoom in or out(Can also disable zoom having this at 0.0)

# Gui settings
export var use_gui = true
export var gui_action = "ui_cancel"

# Intern variables.
var _mouse_offset = Vector2()
var _rotation_offset = Vector2()
var _yaw = 0.0
var _pitch = 0.0
var _total_yaw = 0.0
var _total_pitch = 0.0

var _direction = Vector3(0.0, 0.0, 0.0)
var _speed = Vector3(0.0, 0.0, 0.0)
var _gui

var _triggered=false

const ROTATION_MULTIPLIER = 500

func _ready():
	_check_actions([
		forward_action,
		backward_action,
		left_action,
		right_action,
		gui_action,
		up_action,
		down_action,
		rotate_left_action,
		rotate_right_action,
		rotate_up_action,
		rotate_down_action,
		zoom_in_action,
		zoom_out_action
	])

	if privot:
		privot = get_node(privot)
	else:
		privot = null

	set_enabled(enabled)

	if use_gui:
		_gui = preload("camera_control_gui.gd")
		_gui = _gui.new(self, gui_action)
		add_child(_gui)

func _input(event):
		if len(trigger_action)!=0:
			if event.is_action_pressed(trigger_action):
				_triggered=true
			elif event.is_action_released(trigger_action):
				_triggered=false
		else:
			_triggered=true
		if freelook and _triggered:
			if event is InputEventMouseMotion:
				_mouse_offset = event.relative
			
			_rotation_offset.x = Input.get_action_strength(rotate_right_action) - Input.get_action_strength(rotate_left_action)
			_rotation_offset.y = Input.get_action_strength(rotate_down_action) - Input.get_action_strength(rotate_up_action)
		if movement and _triggered:
			_direction.x = Input.get_action_strength(right_action) - Input.get_action_strength(left_action)
			_direction.y = Input.get_action_strength(up_action) - Input.get_action_strength(down_action)
			_direction.z = Input.get_action_strength(backward_action) - Input.get_action_strength(forward_action)
		if zoom_step > 0.0:
			if event.is_action_pressed(zoom_in_action):
				#_zoomDir = 1#TODO allow for zoom smoothing over time(?)
				zoom_percent += zoom_step
			elif event.is_action_pressed(zoom_out_action):
				#_zoomDir = -1#TODO allow for zoom smoothing over time(?)
				zoom_percent -= zoom_step
			set_zoom(zoom_percent)#Apply/update zoom limit

func _process(delta):
	if _triggered:
		_update_views(delta)

func _update_views(delta):
	if privot:
		_update_distance()
	if freelook:
		_update_rotation(delta)
	if movement:
		_update_movement(delta)

func _physics_process(delta):
	if _triggered:
		_update_views_physics(delta)

func _update_views_physics(delta):
	# Called when collision are enabled
	_update_distance()
	if freelook:
		_update_rotation(delta)

	var space_state = get_world().get_direct_space_state()
	var obstacle = space_state.intersect_ray(privot.get_translation(),  get_translation())
	if not obstacle.empty():
		set_translation(obstacle.position.move_toward(translation, -collision_buffer))

func _update_movement(delta):
	var offset = max_speed * acceleration * _direction
	
	_speed.x = clamp(_speed.x + offset.x, -max_speed.x, max_speed.x)
	_speed.y = clamp(_speed.y + offset.y, -max_speed.y, max_speed.y)
	_speed.z = clamp(_speed.z + offset.z, -max_speed.z, max_speed.z)
	
	# Apply deceleration if no input
	if _direction.x == 0:
		_speed.x *= (1.0 - deceleration)
	if _direction.y == 0:
		_speed.y *= (1.0 - deceleration)
	if _direction.z == 0:
		_speed.z *= (1.0 - deceleration)
	
	if local:
		translate(_speed * delta)
	else:
		global_translate(_speed * delta)

func _update_rotation(delta):
	var offset = Vector2();
	
	if not freelook_mode == Freelook_Modes.INPUT_ACTION:
		offset += _mouse_offset * sensitivity
	if not freelook_mode == Freelook_Modes.MOUSE: 
		offset += _rotation_offset * sensitivity * ROTATION_MULTIPLIER * delta
	
	_mouse_offset = Vector2()
	
	_yaw = _yaw * smoothness + offset.x * (1.0 - smoothness)
	_pitch = _pitch * smoothness + offset.y * (1.0 - smoothness)
	
	if yaw_limit < 360:
		_yaw = clamp(_yaw, -yaw_limit - _total_yaw, yaw_limit - _total_yaw)
	if pitch_limit < 360:
		_pitch = clamp(_pitch, -pitch_limit - _total_pitch, pitch_limit - _total_pitch)
	
	_total_yaw += _yaw
	_total_pitch += _pitch
	
	if privot:
		var target = privot.get_translation()
		var dist = get_translation().distance_to(target)
	
		set_translation(target)
		rotate_y(deg2rad(-_yaw))
		rotate_object_local(Vector3(1,0,0), deg2rad(-_pitch))
		translate(Vector3(0.0, 0.0, dist))
	
		if rotate_privot:
			privot.rotate_y(deg2rad(-_yaw))
	else:
		rotate_y(deg2rad(-_yaw))
		rotate_object_local(Vector3(1,0,0), deg2rad(-_pitch))

func _calculated_zoomed_distance() -> float:
	#Uses distance for distMax
	var distMin = (distance * zoom_min)
	var delta = (distance - distMin)
	#Removing the '1.0 -' below will invert zoom value where 0.0 is fully zoomed in.
	return distMin + ((1.0 - zoom_percent) * delta)

func _update_distance():
	var t = privot.get_translation()
	t.z -= _calculated_zoomed_distance()
	set_translation(t)

func _update_process_func():
	# Use physics process if collision are enabled
	if collisions and privot:
		set_physics_process(true)
		set_process(false)
	else:
		set_physics_process(false)
		set_process(true)

func _check_actions(actions=[]):
	if OS.is_debug_build():
		for action in actions:
			if not InputMap.has_action(action):
				print('WARNING: No action "' + action + '"')

func set_privot(value):
	privot = value
	_update_process_func()
	if len(trigger_action)!=0:
		_update_views(0)

func set_collisions(value):
	collisions = value
	_update_process_func()

func set_enabled(value):
	enabled = value
	if enabled:
		Input.set_mouse_mode(mouse_mode)
		set_process_input(true)
		_update_process_func()
	else:
		set_process(false)
		set_process_input(false)
		set_physics_process(false)

func set_smoothness(value):
	smoothness = clamp(value, 0.001, 0.999)

func set_distance(value):
	distance = max(0, value)

func set_zoom_min(value):
	zoom_min = clamp(value, 0.0, 1.0)
func set_zoom(value):
	zoom_percent = clamp(value, 0.0, 1.0)
func set_zoom_step(value):
	zoom_step = clamp(value, 0.0, 1.0)
