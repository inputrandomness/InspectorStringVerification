@abstract class_name StringRegistryFiller
extends Object

## Abstract class for filling string list for InspectorStringVerification plugin.[br][br]
##
## Create an inheriting class to override [method get_registry] and [method check_custom_hint] 
## for custom string registry behavior. In the project settings, select that script as the registry 
## filler, as well as the path to the directory file. See ConstStringNameRegistryFiller 
## as an example.[br][br]


## Returns a list of words based on custom behavior of inheriting class. 
## If the returned list is empty, the plugin will not load.
@abstract func get_registry(object : Object, hint_string : String, directory_file : String) -> Array[String]

## Return true if hint_string contains information that this object recognizes
## and can use, false otherwise. Used to determine whether to abandon loading the
## plugin for an object when InspectorStringVerificationPlugin.always_on is set to false.
@abstract func check_custom_hint(hint_string : String) -> bool
