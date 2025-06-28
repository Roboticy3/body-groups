## Unused! Functionality replaced by https://github.com/SunZiBingFa/import_mixamo-root_motion

## Lock the motion of a Node3D relative to a target Node3D based on the target's
## X, Y, and Z axes. If these axes are unchecked, this node will be constrained
## to the target's origin along these axes each frame.

## This could be a good way to accumulate root motion. Locking X and Y seems to
## do pretty good on a child of a mixamo hip attachment as a substitute for a
## true position root.

extends Node3D

@export_flags("X", "Y", "Z") var axes := 7

@export_node_path("Node3D") var target_path := NodePath("../..")
@onready var target:Node3D = get_node(target_path)

func _process(delta: float) -> void:
	var target_relative := global_position - target.global_position
	
	for i in range(0, 3):
		var erase := (axes >> i) % 2 == 0
		if erase:
			target_relative -= target_relative.project(target.global_basis[i])
	
	global_position = target.global_position + target_relative
