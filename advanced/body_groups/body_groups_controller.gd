extends Node

@export var body_groups:NodeGroupSet

@export var equipped:Dictionary[StringName,bool] = {}

func _ready():
	body_groups.set_group_visible.connect(_on_set_group_visible)

func _on_set_group_visible(g:StringName, v:bool):
	if v:
		show_group(g)
	else:
		hide_group(g)

func show_group(g:StringName):
	for n in body_groups.get_nodes_in_group(g):
		n.set("visible", true)
	equipped[g] = true
	
	resolve()

func hide_group(g:StringName):
	for n in body_groups.get_nodes_in_group(g):
		n.set("visible", false)
	equipped[g] = false
	
	resolve()

func resolve():
	
	#Show all nodes in equipped groups being covered by unequipped groups
	for g in body_groups.get_groups():
		var g_invisible := false if equipped.get(g) else true
		
		if g_invisible:
			for h in get_groups_covered_by(g):
				for n in body_groups.get_nodes_in_group(h):
					for i in body_groups.get_groups_of(n):
						if equipped.get(i):
							n.set("visible", true)
							print("show ", n)
	
	#Hide all nodes in groups covered by equipped groups
	for g in body_groups.get_groups():
		var g_visible := true if equipped.get(g) else false
		
		if g_visible: 
			for h in get_groups_covered_by(g):
				for n in body_groups.get_nodes_in_group(h):
					n.set("visible", false)
					print("hide ", n)

func get_groups_covered_by(g:StringName) -> Array[StringName]:
	var covered_groups:Array[StringName] = []
	
	#`i` iterates through all groups directly covered by `g`
	for n in body_groups.get_nodes_in_group(g):
		for h in body_groups.get_groups_of(n):
			var i = get_covered_group(h)
			if !i: continue
			covered_groups.append(i)
			covered_groups.append_array(get_groups_covered_by(i))
	
	return covered_groups


func get_covered_group(g:StringName):
	if g.begins_with("-"): return g.substr(1)
	return null
