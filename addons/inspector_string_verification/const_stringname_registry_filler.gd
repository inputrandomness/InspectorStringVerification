class_name ConstStringNameRegistryFiller
extends StringRegistryFiller

## Implementation that specifically looks for constant StringNames in a GDScript file

const MAX_LINES = 1000
const COMMENT_CHAR = "#"

static var _debug : bool = false

## Parses the content file line-by-line, only keeping portions prior 
## to the first instance of [member COMMENT_CHAR]. Then attempts to open the
## file, assuming it is a [GDScript] file, and obtains all StringName instances
## defined as member properties of the script, returning that list.
func get_list(directory_file : String) -> Array[String]:
	if _debug: print("Getting list from: " + directory_file)
	var regfile := FileAccess.open(directory_file,FileAccess.READ)
	if not regfile:
		var err := FileAccess.get_open_error()
		printerr("Inspector String Verif.. Error: " + error_string(err) + directory_file +\
				". Be sure correct directory file is set in Project Settings.")
		return []
	var scripts : Array[Script] 
	var line_count := 0
	var the_list : Array[String]
	while not regfile.eof_reached() and line_count < MAX_LINES:
		line_count += 1
		var line := regfile.get_line()
		line = line.split(COMMENT_CHAR)[0]
		line = line.strip_edges()
		if line.length() == 0:
			continue
		var script = load(line) as GDScript
		if not script:
			printerr("StringName Registry: Failed to load script at " + line)
			continue
		the_list.append_array(script.get_script_constant_map().values().filter(is_stringname))
	if _debug: print("Directory found:\n" + "\n".join(the_list)) 
	
	return the_list
		
			
static func is_stringname(s : Variant) -> bool:
	return typeof(s) == TYPE_STRING_NAME
		
