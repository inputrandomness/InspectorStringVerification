@abstract class_name StringRegistryFiller
extends Object

## Abstract class for filling string list for InspectorStringVerification plugin.[br][br]
##
## Create an inheriting class to override the abstract methods
## for custom string registry behavior. In the project settings, select that script as the registry 
## filler, as well as the path to the directory file. See ConstStringNameRegistryFiller 
## as an example.[br][br]

var object : Object # Store the object instance opened in the inspector
var hint_string : String # Store the hint string provided by the property being edited.
var directory_path : String # Store the path to the directory file


## Pass the relevant data to the filler before using. This is separated 
## from [method get_registry] to allow reloading later, if needed.
func setup(obj: Object, hint : String, directory : String) -> void:
	object = obj
	hint_string = hint
	directory_path = directory

## Return true if the filler should reload the list whenever the property is focused.
## If it is time-consuming, this might be problematic for user experience.
@abstract func reload_on_focus() -> bool

## Returns a list of words based on custom behavior of inheriting class. 
## If the returned list is empty, the plugin will not load.
@abstract func get_registry() -> Array[String]

## Return true if hint_string contains information that this object recognizes
## and can use, false otherwise. Used to determine whether to abandon loading the
## plugin for an object when InspectorStringVerificationPlugin.always_on is set to false.
@abstract func check_custom_hint(hint_string : String) -> bool
