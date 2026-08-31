class_name TestingResource
extends Resource

# A sample resource for checking that the verification works in the inspector.


const LOCAL1 := &"Local1"
const LOCAL2 := &"Local2"
const LOCAL3 := &"Local3"
const LOCATE := &"Locate"
const LOCATION := &"Location"
const LOOKY_LOO := &"Looky Loo"
const LOU_FERRIGNO := &"Lou Ferrigno"

@export var category : StringName = "Entities"

## Intended to only be of values in the list stored in [member category].
@export_custom(PROPERTY_HINT_NONE, "listmember:category")
var some_entity : StringName

## Intended to only be of values in the list "Names"
@export_custom(PROPERTY_HINT_NONE, "uselist:Names")
var some_name : StringName

## Should prevent this plugin's custom editor from loading.
@export_custom(PROPERTY_HINT_NONE, "nolist")
var dont_help_me : StringName

## If plugin's always_on setting is false, this should use the default editor.
@export var my_string_name_1 : StringName

## This should use the plugin with all possile strings, no specific list
@export_custom(PROPERTY_HINT_NONE, "uselist:")
var my_string_name_2 : StringName = "Boberio"

## This should only trigger the plugin when the plugin's always_on setting is 
## true, and it should ignore categories and use every word.
@export var default_no_cat : String = "Bobbert"

## This should be ignored by the plugin since it assumes you're
## talking to someone else with an unrecognized hint_string
@export_custom(PROPERTY_HINT_NONE, "other value") 
var unknown_hint : String

## This should use the options provided within the custom export
## hint string. Works with StringName, not just String
@export_custom(PROPERTY_HINT_NONE, "options:Earth,Water,Fire,Air,Magic,Divine,Death")
var like_enum_string_name : StringName

## Use the provided options with a String instead of StringName
@export_custom(PROPERTY_HINT_NONE, "options:ABC,DEF,GHI")
var like_enum_also : String

## This should use whatever constants are defined within this
## file.
@export_custom(PROPERTY_HINT_NONE, "local")
var local_consts : StringName

@export_group("Nested Types")

## For nested data, Godot passes everything after the first colon in the hint to each
## nested property.
@export_custom(PROPERTY_HINT_NONE,":uselist:Names")
var list_of_names : Array[StringName]

## For dictionaries, a semicolon can separate the key and value information.
## However, both the key and value still need the ':' in front.
@export_custom(PROPERTY_HINT_NONE,":uselist:Names;:uselist:Others")
var a_dict : Dictionary[StringName, String]

@export_group("Standard Godot export_enum")
## Standard Godot export_enum with int
@export_enum("String1", "String2", "String3")
var int_ex_enum : int

## Standard Godot export_enum with String
@export_enum("String1", "String2", "String3")
var str_ex_enum : String

## Standard Godot export_enum does not support StringName
#@export_enum("String1", "String2", "String3")
#var stringname_ex_enum : StringName
