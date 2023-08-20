extends Spatial

var rot_speed = 5
var joy_angle = 0
var joy_distance = 0

onready var horizontal_rot = $HorizontalRotation
onready var vertical_rot = $HorizontalRotation/VerticalRotation
onready var camera = $HorizontalRotation/VerticalRotation/Camera


func _physics_process(_delta):
	var input_dir = Input.get_vector(
		"look_left",
		"look_right",
		"look_up",
		"look_down"
	)
	
	var rot_h = (input_dir.x * rot_speed)
	var rot_v = (input_dir.y * rot_speed)
	
	horizontal_rot.rotation_degrees.y += rot_h
	vertical_rot.rotation_degrees.x -= rot_v
	
	vertical_rot.rotation_degrees.x = clamp(vertical_rot.rotation_degrees.x, -30, 30)
	
	joy_distance = (rad2deg(input_dir.angle()) + 180.0) / 360


func get_camera_basis():
	return camera.get_global_transform().basis
