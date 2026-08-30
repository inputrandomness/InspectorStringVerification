class_name StringVerificationPlugin
extends EditorInspectorPlugin

## Parses the provided property and project settings, calls the [StringRegistryFiller] specified in the 
## project settings, and if the filler returns a non-empty list, loads the custom editor.

var _debug : bool = false

func _can_handle(object: Object) -> bool:
	return true
	
	
func _parse_begin(object: Object) -> void:
	InspectorStringVerificationEditorPlugin.refresh_settings()
	
## Use current Project Settings values to load the registry filler, the directory path,
## and other settings (like always_on, and show_on_empty). Send any custom hint info
## to the loaded filler and loads the custom editor.
##
## It will fail to load the editor if:
## - the property being edited is not a String or StringName
## - the filler object fails to load
## - always_on is false and the filler does not return true to check_custom_hint
## - the filler returns an empty list.
func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, 
		hint_string: String, usage_flags: int, wide: bool) -> bool:
	
	if _debug: print("\nISV: Parsing " + name + " with hint string: '" + hint_string + "'")
		
	if type != TYPE_STRING_NAME and type != TYPE_STRING:
		return false
		
	var filler = get_filler()
	if not filler:
		if _debug: print("\nFailed to load filler from Project Settings.")
		return false
	
	var always_on := InspectorStringVerificationEditorPlugin.always_on
	if not (always_on or filler.check_custom_hint(hint_string)):
		if _debug: print("Not in always_on mode and no hint received. ISV won't take over.")
		return false # implicit turn-off
	
	var directory_path : String = InspectorStringVerificationEditorPlugin.registry_directory_path
	var string_list = filler.get_registry(object, hint_string, directory_path)
	if string_list.size() == 0:
		return false # Filler did not provide any words to use
	
	var editor_property := StringVerifyEditorProperty.new()
	editor_property.show_on_empty = InspectorStringVerificationEditorPlugin.show_on_empty
	editor_property.registry = string_list
	add_property_editor(name, editor_property)
	return true

func get_filler() -> StringRegistryFiller:
	var script := load(InspectorStringVerificationEditorPlugin.registry_filler_uid) as Script
	if not script:
		printerr("Failed to load StringRegistryFiller script at " + InspectorStringVerificationEditorPlugin.registry_filler_uid)
		return null
	return script.new() as StringRegistryFiller
