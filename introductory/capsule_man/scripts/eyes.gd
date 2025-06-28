extends Node3D

func _unhandled_input(event:InputEvent):
	if event is InputEventMouseMotion:
		rotation.x -= event.relative.y * 0.002
		get_parent().rotation.y -= event.relative.x * 0.002
