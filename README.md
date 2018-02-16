# Camera Control Script

An easy "plug and play" camera script for the godot engine 3.0 that provides flexible controls (mouselook, movement,...) and an optional ingame control gui.
Useful for development and quick tests.

![Image](editor_settings.png)![Image](ingame_gui.png)

## How to use

There is a demo scene "demo.tscn" where you can test all features and play with the script parameters.
If you don't need the demo put only the "camera_control.gd" and the "camera_control_gui.gd" somewhere in your project folder and connect the camera with the camera_control.gd script.

## Docummentation:

### Settings available via Editor/GDscript:

- bool enable : enable/disable camera controls. Default is true.
- int mouse_mode: Same as Godot's mouse settings by default the mouse is captured:
  - Visible = 0 (MOUSE_MODE_VISIBLE),
  - Hidden = 1 (MOUSE_MODE_HIDDEN),
  - Capture = 2 (MOUSE_MODE_CAPTURED),
  - Confined = 3 (MOUSE_MODE_CONFINED).


- bool mouselook - Enable/disable mouselook. Default is true.
- float sensitivity - Sensitivity of the mouselook. A value between 0 and 1. Default value is 0.5.
- float smoothness - Smoothness of the mouselook. A value between 0,001 and 0,999. Default value is 0.5.
- Spatial privot - Optional privot object for thirdperson like mouselook. Default value is None (no privot).
- bool rotate_privot - Enable/disable if the will be rotated with the camera. Default is false.
- float distance - The distance between the camera and the privot object. Minimum value is 0. Default value is 5.0
- bool rotate_privote - Rotate privot object with the mouselook. Default is false.
- bool collision - The camera avoid it to go through/behind objects. Default is true.
- int yaw_limit - Limit the yaw of the mouselook in Degrees, if limit >= 360 there is no limit. Default value is 360.
- int pitch_limit - Limit the Pitch of the mouselook in Degrees, if limit >= 360 there is no limit. Default value is 360.


- bool movement - Enable/disable camera movement (flying). Default is true.
- float speed - Set movement speed. Default value is 1.0;
- String forword_action - Input Action for fordward movement. Default action is "ui_up".
- String backward_action - Input Action for backward movement. Default action is "ui_down".
- String left_action - Input Action for Left movement. Default action is "ui_left".
- String right_action: Input Action for Right movement. Default action is "ui_right".


- String gui_action - Input Action to show/hide the ingame control gui. Default action is "ui_cancel".
- bool use_gui - Enable/disable ingame gui. Default is true.

### To-do/possible features:
- refactoring
- distance shortcut key.
- improve movement: speed shortcut, acceleration/deceleration...
- multiple camera support/jump between cameras
- screenshot functionality(?)
- more modularisation(?)
- add signal notification(?)
- ...


## License

All parts of this project that are not copyrighted or licensed by someone else are released free under the MIT License - see the LICENSE.md file for details.
Please keep license file, thanks, we are a community! :)
