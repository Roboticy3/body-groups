extends Node

@export var body_groups:NodeGroupSet
@export var use_parent_name := true

func set_item_visible(item:InventoryItem):
	body_groups.signal_set_group_visible(get_item_body_group(item), true)

func set_item_invisible(item:InventoryItem):
	body_groups.signal_set_group_visible(get_item_body_group(item), false)

func get_item_body_group(item:InventoryItem) -> StringName:
	return item.resource_path.get_file().replace(".tres","")
