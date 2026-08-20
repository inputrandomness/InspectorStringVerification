@tool
class_name InspectorStringVerificationEditorPlugin
extends EditorPlugin

## A plugin that checks StringNames as they are typed and compares them against a list of 
## verified StringNames, providing a live-filter dropdown for selection as well as a checkmark
## icon if the value entered is verified.


## The path to the directory file containing information for the StringRegistryFiller
const SETTING_DIRECTORY_FILE_PATH_NAME = "addons/inspector_string_verification/directory_file_path"
const SETTING_DIRECTORY_FILE_PATH_DEFAULT = "res://addons/example/directory.txt"

## The path to the source file of the class inheriting StringRegistryFiller to load the registry 
# from the directory.
const SETTING_REGISTRY_CLASS_PATH_NAME = "addons/inspector_string_verification/registry_class_path"
const SETTING_REGISTRY_CLASS_PATH_DEFAULT = "uid://q37h33d14w6d"

var plugin = StringVerificationPlugin
static var registry_filler_uid : String
static var registry_directory_path : String


func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	plugin = StringVerificationPlugin.new()
	
	if not ProjectSettings.has_setting(SETTING_DIRECTORY_FILE_PATH_NAME):
		ProjectSettings.set_setting(SETTING_DIRECTORY_FILE_PATH_NAME, SETTING_DIRECTORY_FILE_PATH_DEFAULT)

	if not ProjectSettings.has_setting(SETTING_REGISTRY_CLASS_PATH_NAME):
		ProjectSettings.set_setting(SETTING_REGISTRY_CLASS_PATH_NAME, SETTING_REGISTRY_CLASS_PATH_DEFAULT)
	
	ProjectSettings.set_initial_value(SETTING_DIRECTORY_FILE_PATH_NAME, SETTING_DIRECTORY_FILE_PATH_DEFAULT)
	ProjectSettings.set_initial_value(SETTING_REGISTRY_CLASS_PATH_NAME, SETTING_REGISTRY_CLASS_PATH_DEFAULT)
	
	registry_directory_path = ProjectSettings.get_setting(SETTING_DIRECTORY_FILE_PATH_NAME, SETTING_DIRECTORY_FILE_PATH_DEFAULT)
	registry_filler_uid = ProjectSettings.get_setting(SETTING_REGISTRY_CLASS_PATH_NAME, SETTING_REGISTRY_CLASS_PATH_DEFAULT)
		
	ProjectSettings.settings_changed.connect(_on_settings_changed)
	
	ProjectSettings.add_property_info(
		{
			"name" : SETTING_DIRECTORY_FILE_PATH_NAME,
			"type" : TYPE_STRING,
			"hint" : PROPERTY_HINT_FILE_PATH,
			"hint_string" : ""
		}
	)
	
	ProjectSettings.add_property_info(
		{
			"name" : SETTING_REGISTRY_CLASS_PATH_NAME,
			"type" : TYPE_STRING,
			"hint" : PROPERTY_HINT_FILE_PATH,
			"hint_string" : "*.gd"
		}
	)
	add_inspector_plugin(plugin)
	print("StringNameFiltering: EnteringTree")


func _exit_tree() -> void:
	print("StringNameFiltering: Exiting Tree")
	remove_inspector_plugin(plugin)
	plugin = null


func _on_settings_changed() -> void:
	registry_directory_path = ProjectSettings.get_setting(SETTING_DIRECTORY_FILE_PATH_NAME, SETTING_DIRECTORY_FILE_PATH_DEFAULT)
	registry_filler_uid = ProjectSettings.get_setting(SETTING_REGISTRY_CLASS_PATH_NAME, SETTING_REGISTRY_CLASS_PATH_DEFAULT)
