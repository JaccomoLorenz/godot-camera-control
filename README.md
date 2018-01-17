# Camera Control Script

A camera script for the godot engine version 2.1 (3.0 planned) that provides flexible mouselook, movement (flying), ingame control gui.
Useful for development and quick tests.

## Demo

There is a demo scene "demo.tscn" where you can test all features and play with the script parameters.
If you don't need the demo install only the "camera_control.gd" and the "camera_control_gui.gd".

### Paramenters

- Enabled: Enable/disable camera controls.
- Mouselook: Enable/disable mouselook.
- Sensitivity: Sensitivity of the mouselook.
- Smoothness: Smoothness of the mouselook.
- Privot: Optional privot object for thirdperson mouselook.
- Distance: The distance between the camera and the privot object.
- Rotate Privot: Rotate privot object with the mouselook.
- Mouse Mode: Visible, Hidden, Capture mouse.
- Collision: The camera avoid it to go through objects.
- Yaw Limt: Limt the Yaw of the mouselook.
- Pitch Limit: Limit the Pitch of the mouselook.
- Movement: enable/disable camera movement (flying).
- Speed: Set movement speed.
- Forward Action: Input Action for fordward movement.
- Backward Action: Input Action for backward movement.
- Left Action: Input Action for Left movement.
- Right Action: Input Action for Right movement.
- Gui Action: Input Action to open the ingame control gui.

## License

All parts of this project that are not copyrighted or licensed by someone else are released under the MIT License - see the LICENSE.md file for details.
