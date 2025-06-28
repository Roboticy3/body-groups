## Establish a set of relations that showing group "A" will hide "-A", and
## hiding "A" will show "-A". Then, apply these relations to all members of the
## groups.

## Covered and Visible groups will both cover groups that they hide.

extends Node

@export var body_groups:NodeGroupSet

enum BodyMode {
	DISABLED,
	COVERED,
	VISIBLE
}

var body_modes:Dictionary[StringName,BodyMode] = {}

# Initialize coverage with some default value for each node that holds the
#	relation.
func _ready() -> void:
	
	
	#At first, all groups are visible
	for g in body_groups.get_groups():
		print(g, ": ", body_groups.get_nodes_in_group(g))
		body_modes[g] = BodyMode.VISIBLE
	
	#Then, show_group will resolve how these visibilities effect each other.
	for g in body_groups.get_groups():
		show_group(g)
	
	#Finally, connect a signal through the resource so other nodes with access
	#	can toggle groups
	body_groups.set_group_visible.connect(set_group_visibility)

func set_group_visibility(g:StringName, to:bool):
	print("setting group ", g, " to visiblility ", to)
	if to: show_group(g)
	else: hide_group(g)

func show_group(g:StringName) -> void:
	if body_modes[g] == BodyMode.COVERED: return
	
	body_modes[g] = BodyMode.VISIBLE
	
	update_visibility_for_nodes_in(g)
	
	#It might make sense intuitively to check if n in visible before 
	#	covering what is below it. But, since we're trying to show n,
	#	the only way it wouldn't be visible here is if it were covered.
	#So, in both cases, the groups covered by n should be covered.
	for h in get_groups_covered_by(g):
		print("covering ", h)
		body_modes[h] = BodyMode.COVERED
		for n in body_groups.get_nodes_in_group(h):
			set_visibility_of(n,false)

func hide_group(g:StringName):
	#If g was COVERED, do not uncover nodes it was covering.
	#If g was not COVERED, uncover both g and any DISBALED groups covered by it, 
	#	recursively.
	var was_covered := body_modes[g] == BodyMode.COVERED
	
	#Selectively hide and reveal the nodes in this group depending on coverage
	for n in body_groups.get_nodes_in_group(g):
		set_visibility_of(n,false)

	var uncovered := get_groups_covered_by(g)
	if !was_covered: 
		for h in uncovered:
			body_modes[h] = BodyMode.VISIBLE
		
		#Actually show the nodes *after* showing all the groups, so that nodes
		#	in multiple of the revealed groups will not have their visibility 
		#	determined by their order in the tree.
		for h in uncovered:
			print("uncovering ", h)
			update_visibility_for_nodes_in(h)
	
	#Hide after getting covered groups. 
	body_modes[g] = BodyMode.DISABLED

#Show a group without accounting for coverage or affecting `body_modes`.
#Basically just computing the visibility of the group of nodes with the current
#	set of body_modes.
#If g is disabled or covered, this will hide all nodes. Nodes in hidden or 
#	covered groups will be hidden.
func update_visibility_for_nodes_in(g:StringName):
	#Selectively hide and reveal the nodes in this group depending on coverage
	for n in body_groups.get_nodes_in_group(g):
		set_visibility_of(n,true)
		
		#If any group of n is hidden, hide it
		for h in body_groups.get_groups_of(n):
			if body_modes[h] != BodyMode.VISIBLE:
				set_visibility_of(n,false)
				#If this node is hidden, don't try to hide things underneath it.
				break

#Get the groups currently covered by g.
# If g is covering hidden groups, it will search to the groups covered by the 
# hidden groups as well.
func get_groups_covered_by(g:StringName) -> Array[StringName]:
	
	var covered_groups:Array[StringName] = []
	for n in body_groups.get_nodes_in_group(g):
		for h in body_groups.get_groups_of(n):
			if body_modes[h] == BodyMode.DISABLED:
				covered_groups.append_array(get_groups_covered_by(h))
			else:
				var i = get_covered_group(h)
				if i: covered_groups.append(i)
	
	return covered_groups

func set_visibility_of(n:Node, to:bool):
	print("set visibility of ", n, " to ", to)
	n.set("visible", to)

func get_covered_group(of:StringName) -> Variant:
	if of.begins_with("-"): return of.substr(1)
	else: return null
