extends Node

@export var equip_group := "Equip"

func equip(item:InventoryItem):
	for n in get_tree().get_nodes_in_group(equip_group):
		n._on_equip(item)

func unequip(item:InventoryItem):
	for n in get_tree().get_nodes_in_group(equip_group):
		n._on_unequip(item)
