@abstract class_name StringRegistryFiller
extends Object

## Abstract class for filling string registries for InspectorStringVerification plugin.[br][br]
##
## Create an inheriting class to override [method get_registry] for custom string registry 
## behavior. In the project settings, select that script as the registry filler, as well
## as the path to the directory file. See ConstStringNameRegistryFiller as an example.
##
## The return value is a list of words in in the given category, or all words found if 
## no category was specified. See [InspectorStringVerification] for information on specifying
## categories.

## See class documentation
@abstract func get_registry(directory_file : String, category : String = "") -> Array[String]
