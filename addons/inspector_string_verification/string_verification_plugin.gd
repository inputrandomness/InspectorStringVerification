class_name StringVerificationPlugin
extends EditorInspectorPlugin

# Passing category information through @export_custom hint_string parameter
const LITERAL_TAG := "literal:" # The category is provided in @export_custom literally as the remainder of the hint_string
const MEMBER_TAG := "property:" # The category is provided as the string value of the member whose name is the remainder of the hint_string
const OPTIONS_TAG := "options:" # Follow with a comma separated list of valid options. (Mimics @export_enum but supports both String or StringName
const LOCAL_TAG := "local" #  Use only the StringName constants found in the class defining this property
const NO_LIST := "nolist" # The user does not want this plugin enabled for this property when it is on by default


var _debug : bool = true

func _can_handle(object: Object) -> bool:
	return true
	
	
func _parse_begin(object: Object) -> void:
	InspectorStringVerificationEditorPlugin.refresh_settings()
	
	
func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, 
		hint_string: String, usage_flags: int, wide: bool) -> bool:
	
	if _debug: print("\nISV: Parsing " + name + " with hint string: '" + hint_string + "'")
		
	if type != TYPE_STRING_NAME and type != TYPE_STRING:
		return false
		
	var editor_property := StringVerifyEditorProperty.new()
	var category_name := ""
	var custom_hint_received := false
	var always_on := InspectorStringVerificationEditorPlugin.always_on
	var provided_options : Array[String] = []

	if hint_string == NO_LIST:
		if _debug: print("Explicitly told to ignore. ISV won't take over.")
		return false # explicit turn-off
	elif hint_string.begins_with(LITERAL_TAG):
		category_name = hint_string.substr(LITERAL_TAG.length())
		if _debug: print("Using literal category '" + category_name + "'.")
		custom_hint_received = true
	elif hint_string.begins_with(MEMBER_TAG):
		var category_prop_name = hint_string.substr(MEMBER_TAG.length())
		category_name = object.get(category_prop_name)
		if category_name == null:
			printerr("Inspector String Verification was asked to use member '" + category_prop_name +\
				 "' to supply the category for editing '" + name + "', but no such member was found.")
			return false
		elif _debug: print("Using category '" + category_name + "' stored in member '" + category_prop_name + "'.")
		custom_hint_received = true
	elif hint_string.begins_with(OPTIONS_TAG):
		if _debug: print("Using provided options list.")
		provided_options.assign(hint_string.substr(OPTIONS_TAG.length()).split(","))
	elif hint_string == LOCAL_TAG:
		if _debug: print("Using StringName constants local to script as list.")
		var obj_script : Script = object.get_script()
		provided_options.assign(obj_script.get_script_constant_map().values().filter(\
				func (c): return c is StringName))
		
	elif not (always_on or custom_hint_received):
		if _debug: print("Not in always_on mode and no hint received. ISV won't take over.")
		return false # implicit turn-off
	elif hint_string != "":
		if _debug: print("Received unknown hint string. ISV won't take over.")
		return false ## Ignore any other unknown non-empty hint strings
	
	if provided_options.size() > 0:
		editor_property.registry = provided_options
	else:
		var success := set_registry_with_filler(editor_property, category_name)
		if not success:
			return false
		
	editor_property.show_on_empty = InspectorStringVerificationEditorPlugin.show_on_empty

	add_property_editor(name, editor_property)
	return true


func set_registry_with_filler(editor_property : StringVerifyEditorProperty, category_name : String) -> bool:
	var script := load(InspectorStringVerificationEditorPlugin.registry_filler_uid) as GDScript
	if not script:
		printerr("Failed to load StringRegistryFiller script at " + InspectorStringVerificationEditorPlugin.registry_filler_uid)
		return false
	var registry_filler : StringRegistryFiller = script.new()
	var directory_path : String = InspectorStringVerificationEditorPlugin.registry_directory_path
	
	editor_property.registry = registry_filler.get_registry(directory_path, category_name)
	return true
