extends CharacterBody3D

## Based ChatGPT Camera Motion
# I added the splitting up input polling and rotation into _process instead of 
# _physics_process, though.

#...
#I ended up adding a lot. This is basically unrecognizable from the ai version, 
#	though I would still never style a script like this on my own.
const SPEED: float = 5.0


var move_input := Vector3.ZERO
func _process(_delta: float) -> void:
	update_move_input()
	update_rotation()

func update_move_input():
	move_input = Vector3.ZERO

	# Vertical movement (global Y)
	if Input.is_action_pressed("ui_accept"):
		move_input.y += 1
	if Input.is_action_pressed("ui_shift"):
		move_input.y -= 1

	# Horizontal movement (XZ plane aligned with camera heading)
	var yaw_basis := Basis(Vector3.UP, rotation.y)
	if Input.is_action_pressed("ui_right"):
		move_input += yaw_basis.x
	if Input.is_action_pressed("ui_left"):
		move_input -= yaw_basis.x
	if Input.is_action_pressed("ui_down"):
		move_input += yaw_basis.z
	if Input.is_action_pressed("ui_up"):
		move_input -= yaw_basis.z
	
	#Follow the player at a distance if _follow_mode is checked
	if _follow_mode and _target:
		var target_v := (_target.global_position - global_position)
		var target_follow_length := target_v.length() - MIN_TARGET_FOLLOW_DISTANCE
		if target_follow_length > 0.0:
			move_input += target_v.normalized() * target_follow_length

func _physics_process(delta: float) -> void:
	if move_input != Vector3.ZERO:
		velocity = move_input.limit_length(1.0) * SPEED
		move_and_slide()

## Less based ChatGPT mouse controls. Why ugly underscores?
@export_node_path("Node3D") var target_path: NodePath
var _target: Node3D = null
var _follow_mode: bool = true
var _yaw: float = 0.0
var _pitch: float = 0.0
const MOUSE_SENSITIVITY: float = 0.002

const MIN_TARGET_FOLLOW_DISTANCE:float = 3.0

@onready var default_fov:float = $Camera3D.fov

func _ready() -> void:
	if target_path != NodePath():
		_target = get_node(target_path)

	# Initialize yaw and pitch from current rotation
	var euler = rotation
	_yaw = euler.y
	_pitch = euler.x

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_focus_next"):
		_follow_mode = !_follow_mode

	if not _follow_mode and event is InputEventMouseMotion:
		var mouse_event := event as InputEventMouseMotion
		_yaw -= mouse_event.relative.x * MOUSE_SENSITIVITY
		_pitch -= mouse_event.relative.y * MOUSE_SENSITIVITY
		_pitch = clamp(_pitch, deg_to_rad(-89), deg_to_rad(89))  # prevent flipping

#I took the liberty to break this off into its own function. this code is 
# really unsafe but ig chat had to learn from somewhere
func update_rotation():
	# If in follow mode, orient toward the target
	if _follow_mode and _target:
		look_at(_target.global_transform.origin, Vector3.UP)
		#I also also also took the liberty to add this "golf" cam
		$Camera3D.fov = 75.0 / maxf(1.0, global_position.distance_to(_target.global_position) / MIN_TARGET_FOLLOW_DISTANCE - 1)
		
		#I'm just goin crazy with it now
		_yaw = rotation.y
		_pitch = rotation.x
	#I also took the liberty of at least adding this. Still not safe because of
	#	invalid instance etc etc. But whatever.
	elif _follow_mode and !_target:
		printerr("Camera can't follow unspecified target")
	else:
		$Camera3D.fov = default_fov
		rotation.y = _yaw
		rotation.x = _pitch
