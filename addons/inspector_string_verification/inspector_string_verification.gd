@tool
class_name InspectorStringVerificationEditorPlugin
extends EditorPlugin

## A plugin that checks StringNames as they are typed and compares them against a list of 
## verified StringNames, providing a live-filter dropdown for selection as well as a checkmark
## icon if the value entered is verified. NOTE: It doesn't work exactly like the autocomplete
## in the script editor, there is no tab completion and you must press the down arrow or use
## the mouse to interact with the list.
##
## The list of words is provided by a handler extending
## [StringRegistryFiller] which may support pre-filtering with categories.
## [br][br]
## Options: [br]
## - [member registry_directory_path] : Path of the directory file with data for sources of strings.[br]
## - [member registry_filler_uid] : Path/uid of the class extending [StringRegistryFiller] that fills the list.[br]
## - [show_on_empty] : (bool) true if the popup list should be shown when the line edit is empty.[br]
## - [always_on] : (bool) true if this plugin should override the default String or StringName editor  
## in the inspector for every such property in the project, unless otherwise told not to. Can use 
## @export_custom with hint_string set to the value of [member StringVerificationPlugin.NO_LIST] to
## prevent this plugin from overriding. If this is false, can instead use the other hint_string options
## in [StringVerificationPlugin] to ask this plugin to activate as specified. If no category is desired,  
## just using @export when [member always_on] is true, and or @export_custom with "literal:" should work when
## it is false.
## [br][br]
## Usage of the plugin for a specific property can be set, either to use a specific category through @custom_export(PROPERTY_HINT_NONE, hint_string)
## where hint_string is one of:[br]
## - "literal:[CATEGORY_NAME]" - and [CATEGORY_NAME] is the string literal name for the category. Use "literal:" if [member always_on] is
## false and you want this property to use the plugin without any category.[br]
## - "property:[MEMBER_NAME]" - and [MEMBER_NAME] is the string literal name of a [String] or [StringName] member in the same object that holds the name of the category.[br]
## - "nolist" - explicitly do not use this plugin when editing this property in the inspector.[br]
## Any other literal passed as a hint_string to @custom_export will cause the plugin to ignore this property.

## The path to the directory file containing information for the StringRegistryFiller
const SETTING_DIRECTORY_FILE_PATH_NAME = "addons/inspector_string_verification/directory_file_path"
const SETTING_DIRECTORY_FILE_PATH_DEFAULT = "res://addons/inspector_string_verification/example/directory.txt"

## The path to the source file of the class inheriting StringRegistryFiller to load the registry 
## from the directory.
const SETTING_REGISTRY_CLASS_PATH_NAME = "addons/inspector_string_verification/registry_class_path"
const SETTING_REGISTRY_CLASS_PATH_DEFAULT = "uid://q37h33d14w6d"

## Whether an empty lineeditor should trigger showing all valid words. For very long lists this
## may be undesirable. 
const SETTING_SHOW_ON_EMPTY_NAME = "addons/inspector_string_verification/show_on_empty"
const SETTING_SHOW_ON_EMPTY_DEFAULT = false

## Whether the plugin tried to work for every [String] or [StringName] in the project unless told 
## not to by the @export_custom on the property, user should have to explicitly specify with 
## @export_custom when the plugin is meant to be used to edit that property in the inspector.
const SETTING_ALWAYS_ON_NAME = "addons/inspector_string_verification/always_on"
const SETTING_ALWAYS_ON_DEFAULT = true

var plugin = StringVerificationPlugin
static var registry_filler_uid : String
static var registry_directory_path : String
static var show_on_empty : bool
static var always_on : bool

static var _debug : bool = true # Show debug messages

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	plugin = StringVerificationPlugin.new()
	
	setup_setting(SETTING_DIRECTORY_FILE_PATH_NAME, SETTING_DIRECTORY_FILE_PATH_DEFAULT,
			TYPE_STRING,PROPERTY_HINT_FILE_PATH, "")
	setup_setting(SETTING_REGISTRY_CLASS_PATH_NAME, SETTING_REGISTRY_CLASS_PATH_DEFAULT,
			TYPE_STRING, PROPERTY_HINT_FILE_PATH, "*.gd")
	setup_setting(SETTING_SHOW_ON_EMPTY_NAME, SETTING_SHOW_ON_EMPTY_DEFAULT, TYPE_BOOL, PROPERTY_HINT_NONE, "")
	setup_setting(SETTING_ALWAYS_ON_NAME, SETTING_ALWAYS_ON_DEFAULT, TYPE_BOOL, PROPERTY_HINT_NONE, "")
	
	ProjectSettings.set_initial_value(SETTING_DIRECTORY_FILE_PATH_NAME, SETTING_DIRECTORY_FILE_PATH_DEFAULT)
	ProjectSettings.set_initial_value(SETTING_REGISTRY_CLASS_PATH_NAME, SETTING_REGISTRY_CLASS_PATH_DEFAULT)
	ProjectSettings.set_initial_value(SETTING_SHOW_ON_EMPTY_NAME, SETTING_SHOW_ON_EMPTY_DEFAULT)
	
	refresh_settings()
	ProjectSettings.settings_changed.connect(refresh_settings)
	
	add_inspector_plugin(plugin)
	if _debug: print("StringNameFiltering: EnteringTree")


func _exit_tree() -> void:
	if _debug: print("StringNameFiltering: Exiting Tree")
	remove_inspector_plugin(plugin)
	plugin = null


## Checks if the setting exists and if not, sets it. Adds initial value, and adds property info.
func setup_setting(name :String, default_val : Variant, type : Variant.Type, hint :PropertyHint, hint_string : String) -> void:
	if not ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, default_val)
	ProjectSettings.set_initial_value(name, default_val)
	ProjectSettings.add_property_info({"name" : name, "type" : type, "hint" : hint, "hint_string" : hint_string})


static func refresh_settings() -> void:
	registry_directory_path = ProjectSettings.get_setting(SETTING_DIRECTORY_FILE_PATH_NAME, SETTING_DIRECTORY_FILE_PATH_DEFAULT)
	registry_filler_uid = ProjectSettings.get_setting(SETTING_REGISTRY_CLASS_PATH_NAME, SETTING_REGISTRY_CLASS_PATH_DEFAULT)
	show_on_empty = ProjectSettings.get_setting(SETTING_SHOW_ON_EMPTY_NAME, SETTING_SHOW_ON_EMPTY_DEFAULT)
	always_on = ProjectSettings.get_setting(SETTING_ALWAYS_ON_NAME, SETTING_ALWAYS_ON_DEFAULT)
