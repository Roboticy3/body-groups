## An inventory item.
## Equipment should be saved to a file and named the body group that it will 
##	be displayed on.

extends Resource
class_name InventoryItem

#The display texture of this item in the inventory
@export var texture:Texture2D

#Name and description
@export var display_name:String
@export_multiline var description:String

#A list of places this item can be stored. For example:
#	Gear - stored in the equipment panel
#	Hat - goes in the hat slot in equipment
#	Key - stored in the key panel
#	Shirt - goes in the shirt slot in equipment
# and so on.
@export var types:Array[StringName]

#Set to false to allow for multiple of this item to be added to inventory lists.
@export var single:=true

func _to_string() -> String:
	return "InventoryItem<{}, {}>".format([display_name, types], "{}")
