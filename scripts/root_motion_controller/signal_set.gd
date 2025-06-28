## Signals have a limitation where bound arguments, such as the name of a
## property a value is being assigned to, is always passed after a value. This
## is the reverse of the powerful "set" method used by all objects in Godot.
##
## correct syntax:                 signal syntax:
##    set("property name", value)       emit(value) binds("property name")
##
## This script just defines a function to fix this issue. May be unnecessary.

extends Node

func signal_set(value:Variant, property:StringName):
	set(property, value)
