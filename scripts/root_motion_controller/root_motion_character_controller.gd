## CharacterBody3D controlled exclusively by the root motion track of an
## AnimationMixer, which is generally expected to use physics processing to sync
## properly with this script.

extends CharacterBody3D

@export_node_path("AnimationMixer") var mixer_path := NodePath("Acountant/AnimationTree")
@onready var mixer:AnimationMixer = get_node(mixer_path)

#velocity due to acceleration stored separately so it can be computed into the 
#	actual velocity alongside root motion.
var sub_velocity := Vector3.ZERO
func _physics_process(delta: float) -> void:
	
	if is_on_floor():
		#flatten acceleration velocity to the ground
		sub_velocity -= sub_velocity.project(get_gravity())
	else:
		sub_velocity += get_gravity() * delta
	
	velocity = get_root_motion_velocity(delta) + sub_velocity
	move_and_slide()
	
	quaternion *= mixer.get_root_motion_rotation()

func get_root_motion_velocity(delta:float) -> Vector3:
		return mixer.get_root_motion_position() / delta
