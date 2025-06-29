## Store a list of inventory items, emit events when items are added and removed
extends Node

#To reference the same item list as this manager, copy this resource in the editor
@export var items:InventoryItemSet

func _ready():
	for i in items.items:
		if i: item_added.emit(i)
	
signal item_added(item:InventoryItem)
signal item_removed(item:InventoryItem)

# When adding an item, the default slot is after the end of the array, or zero
#	if new slots cannot be added.
func add_item(item:InventoryItem) -> bool:
	if item.single:
		for i in items.items:
			if i == item: return false
	
	items.items.append(item)
	item_added.emit(item)
	return true

func remove_item(item:InventoryItem):
	for i in items.items.size():
		if items.items[i] == item: 
			items.items.remove_at(i)
			item_removed.emit(item)
			return true
	return false
	
