## Unused!

@tool

extends Node3D 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	set_quaternion(get_quaternion() * $AnimationTree.get_root_motion_rotation())
	rotation.y = 0

func _on_animation_changed(to):
	print("reset transform")
	transform = Transform3D()
