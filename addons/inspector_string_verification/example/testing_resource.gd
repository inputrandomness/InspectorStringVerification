class_name TestingResource
extends Resource

# A sample resource for checking that the verification works in the inspector.

@export var category : StringName = "Entities"

## Intended to only be of values in the category stored in [member category].
@export_custom(PROPERTY_HINT_NONE, "property:category")
var some_entity : StringName

## Intended to only be of values in the category "Names"
@export_custom(PROPERTY_HINT_NONE, "literal:Names")
var some_name : StringName

## Should prevent this plugin's custom editor from loading.
@export_custom(PROPERTY_HINT_NONE, "nolist")
var dont_help_me : StringName

## If plugin's always_on setting is false, this should use the default editor.
@export var my_string_name_1 : StringName

## This should use the plugin with all possile strings, no category
@export_custom(PROPERTY_HINT_NONE, "literal:")
var my_string_name_2 : StringName = "Boberio"

## This should only trigger the plugin when the plugin's always_on setting is 
## true, and it should ignore categories and use every word.
@export var default_no_cat : String = "Bobbert"

## This should be ignored by the plugin since it assumes you're
## talking to someone else with an unrecognized hint_string
@export_custom(PROPERTY_HINT_NONE, "other value") 
var unknown_hint : String
