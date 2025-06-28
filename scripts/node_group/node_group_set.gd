## Approximate the experience of if Godot had local groups.

## What it does have is a special function for use with the body groups scripts.
## `signal_set_group_visible` will send a signal through the resource, allowing 
## logic_group_controller.gd and logic_group_toggler.gd to interact through the
## resource itself.
extends Resource
class_name NodeGroupSet

#map between groups and nodes
@export var groups:Dictionary[StringName,NodeGroup]

#map between nodes and groups
var total:Dictionary[Node,Array]

func add_node_to_group(n:Node, g:StringName) -> bool:
	var group = groups.get(g)
	var found = true
	if !(group is NodeGroup):
		var new_group := NodeGroup.new()
		print("created group ", new_group)
		groups[g] = new_group
		group = new_group
		found = false
	
	if !Engine.is_editor_hint(): 
		group.add_node(n)
		
		if total.has(n):
			total[n].append(g)
		else:
			total[n] = [g]
	return found

func get_nodes_in_group(g:StringName) -> Array[Node]:
	if !groups.has(g): return []
	return groups[g].nodes

func get_groups() -> Array[StringName]:
	return groups.keys()

func get_nodes():
	return total.keys()

func get_groups_of(n:Node):
	return total[n]

signal set_group_visible(g:StringName, v:bool)
func signal_set_group_visible(g:StringName, v:bool) -> void:
	set_group_visible.emit(g,v)
