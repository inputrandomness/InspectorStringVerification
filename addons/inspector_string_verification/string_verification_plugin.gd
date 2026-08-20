class_name StringVerificationPlugin
extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
	return true
	
func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, 
		hint_string: String, usage_flags: int, wide: bool) -> bool:
	
	if type == TYPE_STRING_NAME or type == TYPE_STRING:
		print("Adding property editor.")
		add_property_editor(name, StringVerifyEditorProperty.new())
		return true
		
	return false
