## Add direct children to NodeGroups. If these NodeGroups are assigned ahead of 
## time in the editor, other nodes can access the resources to use the local
## groups for their own purposes.

## The adding is done by setup(), based on the names of each direct child. Since
## this is for body groups, each name can also contain a list of groups it wants
## to hide then visible.

## Groups are comma-separated strings in the node's name.

## body_groups_controller uses special syntax with group names that start with -
## Since I also confuse this for a separator, I added an error message for when
## - is found in a group name but not at the beginning.
extends Node

#Press Setup Groups, then copy this resource to get access to them.
@export var local_groups:NodeGroupSet

func _ready():
	setup()

func setup() -> void:
	if !(local_groups is NodeGroupSet):
		local_groups = NodeGroupSet.new()
	
	for c in get_children():
		process_node(c)

func process_node(n:Node) -> void:
	
	for g in n.name.split(","):
		if g.find("-") > 0:
			printerr("- found after the beginning of a group name, are you sure you didn't miss a comma?")
		local_groups.add_node_to_group(n, g)
