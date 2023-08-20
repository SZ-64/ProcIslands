extends KinematicBody

const JUMP = 10
const SPEED = 20.5
const SPRINT_SPEED = 30.0
const GRAVITY = -0.4
const MAX_FALL_SPEED = 30
const ACCEL = 10
const DECEL = 5

const AIR_ACCEL_DAMPER = 0.05
const AIR_DECEL_DAMPER = 0.05
const AIR_MOTION_FACTOR = 0.45

const DEAD_ZONE = 0.2
const V_LOOK_SENSE_STICK = 0.05
const H_LOOK_SENSE_STICK = 0.05
const V_LOOK_SENSE_MOUSE = 0.001
const H_LOOK_SENSE_MOUSE = 0.001

export var invert_x = -1
export var invert_y = 1

var velocity = Vector3()
var acceleration = 0
var y_velo = 0
var is_sprinting = false

onready var camera = $CameraController


func _physics_process(delta):
	
	var on_floor = is_on_floor()
	var dir = Vector3()
#	var angle = 0
	
	dir = _get_move_direction(dir, on_floor)
	dir = _handle_sprint(dir, on_floor)
#	angle = _get_move_rotation()
	
	var new_pos = Vector3(dir.x, 0, dir.z)
	var ground_speed = Vector3(velocity.x, 0, velocity.z)
	if on_floor:
		if new_pos.dot(ground_speed) > 0:
			acceleration = ACCEL
		else:
			acceleration = DECEL
	else:
		if new_pos.dot(ground_speed) > 0:
			acceleration = ACCEL * AIR_ACCEL_DAMPER
		else:
			acceleration = DECEL * AIR_DECEL_DAMPER
	
	ground_speed = ground_speed.linear_interpolate(new_pos, acceleration * delta)
	
	velocity.x = ground_speed.x
	velocity.y = _handle_jump(on_floor)
	velocity.z = ground_speed.z
	
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))

func _get_move_direction(dir: Vector3, on_floor: bool):
	var cam_dir = camera.get_camera_basis()
	if on_floor:
		if Input.is_action_pressed("move_forward"):
			dir -= cam_dir.z
		elif Input.is_action_pressed("move_backward"):
			dir += cam_dir.z
		if Input.is_action_pressed("move_left"):
			dir -= cam_dir.x
		elif Input.is_action_pressed("move_right"):
			dir += cam_dir.x
	
	return dir


func _handle_sprint(dir : Vector3, on_floor : bool):
	if on_floor:
		if Input.is_action_pressed("move_sprint"):
			is_sprinting = true
			return dir.normalized() * SPRINT_SPEED
		else:
			is_sprinting = false
			return dir.normalized() * SPEED
	else:
		if is_sprinting:
			return dir.normalized() * SPRINT_SPEED
		else:
			return dir.normalized() * SPEED


func _get_move_rotation():
	var dir = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)
	
	var angle = transform.basis.z.angle_to(camera.get_camera_basis().z)
	if dir.x > 0.5 or dir.x < -0.5 or dir.y > 0.5 or dir.y < -0.5:
		angle += (rad2deg(dir.angle()) + 90.0) * -1
	
	return angle


func _handle_jump(on_floor : bool):
	y_velo += GRAVITY
	if on_floor and Input.is_action_just_pressed("move_jump"):
		y_velo = JUMP
	if on_floor and y_velo <= 0:
		y_velo = -0.1
	if y_velo < -MAX_FALL_SPEED:
		y_velo = -MAX_FALL_SPEED

	return y_velo
