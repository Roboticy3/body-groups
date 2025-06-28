## Node3D controlling animations via signals based on input. Either directional
## input or setting a target.

extends Node3D

@export var mode := Mode.FOLLOW
enum Mode {
	FOLLOW = 0,
	STICK
}

signal local_target_direction_changed(to:Vector2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match mode:
		Mode.FOLLOW: update_follow()
		Mode.STICK: update_stick(delta)

var interpolated_input := Vector2.ZERO
const INTERPOLATION_SPEED := 5.0
#emit local_target_direction_changed with the current input direction
func update_stick(delta:float):
	interpolated_input = interpolated_input.move_toward(
		Input.get_vector("m_left","m_right","m_down","m_up"),
		delta * INTERPOLATION_SPEED
	)
	
	local_target_direction_changed.emit(interpolated_input)

#emit local_target_direction_changed with the best possible direction towards
#	the current target.
func update_follow():
	pass
