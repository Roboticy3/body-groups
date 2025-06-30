
extends Node

@export var target_property := ""

signal direction_changed(property:StringName, to:Vector2)

var interpolated_input := Vector2.ZERO
const INTERPOLATION_SPEED := 5.0
#emit local_target_direction_changed with the current input direction
func _process(delta:float):
	interpolated_input = interpolated_input.move_toward(
		Input.get_vector("m_left","m_right","m_down","m_up"),
		delta * INTERPOLATION_SPEED
	)
	
	direction_changed.emit(target_property, interpolated_input)
