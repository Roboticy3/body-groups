## Grab a set of items from an inventory manager child and display them as an
## ItemList. The type of items that can be stored here are determined by the 
## name of the node, which should be found in each item's type list.

## Items can be moved between two lists as long as they both match its type in 
## this way. 
extends ItemList

#Keep track of the actual item list.
var items:Array[InventoryItem] = []
@export var max_size := 0

@export var ui_group := "Inventory"
@export var equip_group := ""

#Call this to pick up an item. Also used by `_on_item_activated` to test if an 
#	item can be transfered, thus the boolean return value.
func _on_add_item(item:InventoryItem) -> bool:
	
	if max_size > 0 and item_count > max_size: return false
	
	#Check type of the item against types that can be stored here.
	if !(name in item.types): return false
	
	#Check if the item cannot be added because it is single and already present
	if item.single and item in items: return false
	
	add_item(item.display_name, item.texture)
	items.append(item)
	inventory_item_added.emit(item)
	return true
#Emitted when _on_add_item succeeds. No arguments passed because this is meant 
#	to be used to effect the actual visibility of the body groups.
signal inventory_item_added(item:InventoryItem)

func _on_remove_item(item:InventoryItem) -> bool:
	for i in items.size():
		if items[i] == item:
			remove_item(i)
			items.remove_at(i)
			inventory_item_removed.emit(item)
			return true
	return false
signal inventory_item_removed(item:InventoryItem)

func _init() -> void:
	#Remove any items added through the editor.
	clear()

func _ready():
	
	#Register this ui component so it is activated and deactivated when
	#	necessary. 
	add_to_group(ui_group)
	#Selecting an item will make all of its groups `available`, indicating the 
	#	item can be moved there, and vice-versa for the other lists.
	item_selected.connect(_on_item_selected)
	
	#Changing visibility will effectively "clear" the selection, making the type
	#	available. This does not clean up all groups effected by previous
	#	selections, just enough to make a new selection.
	visibility_changed.connect(_on_clear_selection)
	#Clearing the selection... also clears the selection.
	empty_clicked.connect(_on_clear_selection.unbind(2))
	
	#When an item is activated, try to move it to another list by looking
	#	through the ui group for a valid drop candidate.
	item_activated.connect(_on_item_activated)


#Make lists available or unavailable based on if their type matches the last 
#	selected item.
func _on_item_selected(i:int):
	var item := items[i]
	
	for n in get_tree().get_nodes_in_group(ui_group):
		#print("making node ", n, " available ", should_be_available)
		n.toggle_available(n.name in item.types)

#Clear the selection, and make all lists available again.
signal selection_cleared
func _on_clear_selection():
	deselect_all()
	for n in get_tree().get_nodes_in_group(ui_group):
		n.toggle_available(true)
	selection_cleared.emit()

#Change the visibility and interactivity of this list.
@export var unavailable_modulate := Color(1.0,1.0,1.0,0.7)
func toggle_available(to:bool):
	if to:
		modulate = Color.WHITE
		mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		modulate = unavailable_modulate
		mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_item_activated(i:int):
	var item := items[i]
	
	#Try to move the item to another node in the group.
	for n in get_tree().get_nodes_in_group(ui_group):
		if n == self: continue
		if n._on_add_item(item): 
			_on_remove_item(item)
			_on_clear_selection()
			return
