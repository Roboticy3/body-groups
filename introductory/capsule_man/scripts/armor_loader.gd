extends Node

@export var load_list:Array[PackedScene] = []
var load_map:Dictionary[StringName, PackedScene] = {}

@export var equip_group := "Equip"

func _ready():
	add_to_group(equip_group)
	
	#sort the load_list into a mapping for faster access.
	for l in load_list:
		var key := get_saved_resource_name(l)
		load_map[key] = l

#cut off the .tres or .blend at the end of the file name
var re := RegEx.create_from_string(r"\..*")
func get_saved_resource_name(r:Resource) -> StringName:
	return re.sub(r.resource_path.get_file(), "")

func _on_equip(item:InventoryItem):
	
	var i_name := get_saved_resource_name(item)
	#print(self, " trying to equip ", i_name, " from ", load_map)
	var l = load_map.get(i_name)
	if l is PackedScene:
		var n:Node = l.instantiate()
		n.name = i_name
		add_child(n)

func _on_unequip(item:InventoryItem):
	var i_name := get_saved_resource_name(item)
	for c in get_children():
		if c.name == i_name:
			remove_child(c)
