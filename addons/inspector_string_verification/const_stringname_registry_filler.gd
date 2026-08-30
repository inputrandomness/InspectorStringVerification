class_name ConstStringNameRegistryFiller
extends StringRegistryFiller

## Implementation that specifically looks for constant StringNames in a Script file. [br]
##
## Supports a variety of options specified at the individual property level,
## through [code]@custom_export(PROPERTY_HINT_NONE, hint_string)[/code].[br][br]
## 
## Constraining the acceptable words to a specific list is enabled with the
## options [code]uselist:ListName[/code] and [code]listmember:OtherProperty[/code] (where 
## [code]OtherProperty[/code] is another property in the same class whose value at the time of 
## loading in the editor is [code]"ListName"[/code]. Both require 
## valid list to a sublist whose line in the directory file has the tag [code]LIST=ListName[/code]. 
## (Check the example directory.txt file to see usage.)[br][br] 
##
## The following hint_strings can be used:[br]
##
## - [code]"uselist:[NAME]"[/code] - specifies where [NAME] is the string literal name for the list. Use "uselist:" if
## the always_on setting is false and you want this property to use the plugin
## without any category.[br]
##[br][br]
## - [code]"listmember:[MEMBER]"[/code] - and [MEMBER] is the string literal name of a [String] or [StringName] member in the same object that holds the name of the category.[br]
##[br][br]
## - [code]"options:Option1,Option2,etc"[/code] - mimic the behavior of [code]@export_enum[/code], except supports
## [StringNames], not just [Strings].
##[br][br]
## - [code]"local"[/code] - Load all constant [StringName]s from the object being edited. 
##[br][br] 
## - [code]"nolist"[/code] - explicitly do not use this plugin when editing this property in the inspector.[br]
##  Any other literal passed as a hint_string to @custom_export will cause the plugin 
##to ignore this property.

const MAX_LINES = 10000 ## Sanity check
const COMMENT_CHAR = "#"  ## Everything in a line from this character on will be stripped

## Defines a named list. Add this after the file uid and place a list name after the = sign. 
## Multiple files can be combined into a single list by reusing the same list name.
const CATEGORY_TAG = "LIST=" 
const DEFAULT_CATEGORY_NAME = ""

# Passing category information through @export_custom hint_string parameter

## The list name is provided in @export_custom literally as the remainder of the hint_string
const LITERAL_TAG := "uselist:" 

## The list name is provided as the string value of the member whose name is the remainder of the hint_string
const MEMBER_TAG := "listmember:" 

## Follow with a comma separated list of valid options. (Mimics @export_enum but supports both String or StringName
const OPTIONS_TAG := "options:" 

## Use only the StringName constants found in the class defining this property
const LOCAL_TAG := "local" 

## The user does not want this plugin enabled for this property when it is on by default
const NO_LIST := "nolist" 


static var _debug : bool = false


static func is_stringname(s : Variant) -> bool:
	return typeof(s) == TYPE_STRING_NAME

func reload_on_focus() -> bool:
	return true

## Check whether the hint string found in @export_custom is something
## this filler is expecting.
func check_custom_hint(hint_string : String) -> bool:
	return hint_string.begins_with(LITERAL_TAG) or\
			hint_string.begins_with(MEMBER_TAG) or\
			hint_string.begins_with(OPTIONS_TAG) or\
			hint_string == LOCAL_TAG or\
			hint_string == NO_LIST

## Returns a list of words based on the hint_string provided. An empty list
## means do not use the plugin, since there are no strings.
func get_registry() -> Array[String]:
	var category_name := ""
	var string_list : Array[String]
	
	## Each option should either assign the word list or itnentionally leave it empty.
	
	if hint_string == NO_LIST:
		if _debug: print("Explicitly told to ignore. ISV won't take over.")
		pass # We'll return an empty list.
		
	elif hint_string.begins_with(LITERAL_TAG):
		category_name = hint_string.substr(LITERAL_TAG.length())
		string_list.assign(load_from_file(directory_path, category_name))
		if _debug: print("Using literal category '" + category_name + "'.")
		
	elif hint_string.begins_with(MEMBER_TAG):
		var category_prop_name = hint_string.substr(MEMBER_TAG.length())
		category_name = object.get(category_prop_name)
		if category_name == null:
			printerr("Inspector String Verification was asked to use member '" + category_prop_name +\
				 "' to supply the category for editing '" + object.name + "', but no such member was found.")
			return []
		else:
			string_list.assign(load_from_file(directory_path, category_name))
			if _debug: print("Using category '" + category_name + "' stored in member '" + category_prop_name + "'.")
	
	elif hint_string.begins_with(OPTIONS_TAG):
		if _debug: print("Using provided options list.")
		string_list.assign(hint_string.substr(OPTIONS_TAG.length()).split(","))
		
	elif hint_string == LOCAL_TAG:
		if _debug: print("Using StringName constants local to script as list.")
		var obj_script : Script = object.get_script()
		var constants = obj_script.get_script_constant_map().values()
		string_list.assign(constants.filter(func (c): return c is StringName))
		
	else: # By default just load everything in the directory file
		string_list.assign(load_from_file(directory_path))

	return string_list


## Parses the content file line-by-line, only keeping portions prior 
## to the first instance of [member COMMENT_CHAR]. Then attempts to open the
## file and obtain all StringName instances
## defined as member properties of the script, returning that list.
## A line may optionally following space after the source path but before the comment use the [member CATEGORY_TAG]
## to specify a category. If [param use_category] is provided, only adds words from sources
## that match that category. Otherwise, adds all sources.
func load_from_file(directory_file : String, use_category : String = DEFAULT_CATEGORY_NAME) -> Array[String]:
	if _debug: print("Getting list from: " + directory_file)
	var regfile := FileAccess.open(directory_file,FileAccess.READ)
	if not regfile:
		var err := FileAccess.get_open_error()
		printerr("Inspector String Verif.. Error: " + error_string(err) + directory_file +\
				". Be sure correct directory file is set in Project Settings.")
		return []
	
	var the_registry : Array[String]
	var line_count := 0
	var source : String
	var category : String
	while not regfile.eof_reached() and line_count < MAX_LINES:
		line_count += 1
		var line := regfile.get_line()
		
		# Throw away anything after the comment character
		line = line.split(COMMENT_CHAR)[0]
		
		
		if line.containsn(CATEGORY_TAG):
			var source_and_cat = line.split(CATEGORY_TAG)
			source = source_and_cat[0]
			category = source_and_cat[1]
		else:
			source=line
			category = DEFAULT_CATEGORY_NAME
		
		source = source.strip_edges()
		category = category.strip_edges()
		
		if use_category != DEFAULT_CATEGORY_NAME and category != use_category:
			continue 
			
		if source.length() == 0:
			continue
		var script = load(source) as Script
		if not script:
			printerr("StringName Registry: Failed to load script at " + source)
			continue
		the_registry.append_array(script.get_script_constant_map().values().filter(is_stringname))
		
	if _debug: print("Directory found category '" + category + "':\n" + "\n".join(the_registry)) 
	
	return the_registry
