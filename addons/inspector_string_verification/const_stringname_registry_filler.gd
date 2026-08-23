class_name ConstStringNameRegistryFiller
extends StringRegistryFiller

## Implementation that specifically looks for constant StringNames in a GDScript file

const MAX_LINES = 10000
const COMMENT_CHAR = "#"
const CATEGORY_TAG = "CATEGORY="
const DEFAULT_CATEGORY_NAME = ""

static var _debug : bool = true

## Parses the content file line-by-line, only keeping portions prior 
## to the first instance of [member COMMENT_CHAR]. Then attempts to open the
## file, assuming it is a [GDScript] file, and obtains all StringName instances
## defined as member properties of the script, returning that list.
## A line may optionally following space after the source path but before the comment use the [member CATEGORY_TAG]
## to specify a category. If [param use_category] is provided, only adds words from sources
## that match that category. Otherwise, adds all sources.
func get_registry(directory_file : String, use_category = DEFAULT_CATEGORY_NAME) -> Array[String]:
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
		var script = load(source) as GDScript
		if not script:
			printerr("StringName Registry: Failed to load script at " + source)
			continue
		the_registry.append_array(script.get_script_constant_map().values().filter(is_stringname))
		
	if _debug: print("Directory found category '" + category + "':\n" + "\n".join(the_registry)) 
	
	return the_registry
	
	
static func is_stringname(s : Variant) -> bool:
	return typeof(s) == TYPE_STRING_NAME
