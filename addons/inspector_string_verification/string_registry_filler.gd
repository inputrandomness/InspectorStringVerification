@abstract class_name StringRegistryFiller
extends Object

## Abstract class for filling string registries for InspectorStringVerification plugin.


## Create an inheriting class to override this function for custom string registry 
## behavior. In the project settings, select that script as the registry filler, as well
## as the path to the directory file. See ConstStringNameRegistryFiller as an example.
@abstract func get_list(directory_file : String) -> Array[String]
