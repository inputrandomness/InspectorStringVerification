# Inspector String Verification
A Godot inspector plugin for live-filtering `Strings` or `Stringnames` when edited in the inspector, along with multiple options for feeding a list of desired strings to the editor. Provides a check-mark when a value is verified, but does not prevent entering invalid values.

## Usage and Behavior
When editing a resource in the inspector with exported `Strings` or `StringNames`, this add-on opens a live-filtered dropdown list in a popup panel for viewing matching names from the registry and shows a verification check-mark when the value in the property is in the registry. Live-filtering is through an `ItemList` in a `PanelContainer` on a high-valued `CanvasLayer`, and the popup currently does not adjust if it goes off-screen. In most cases, that is not a problem, but that is planned future work.

The list is repopulated whenever a resource is opened in the inspector, so you don't have to do anything special if you change the directory.

Default behavior is provided through a provided "filler" class which may use a directory file to locate string lists and provides a few different usages through the `@export_custom` hint string. Optionally, for custom list-creation you can 
implement your own list filler class by extending `StringRegistryFiller` as desired, in which case the directory file may contain whatever data is expected by your custom filler class and the custom hint string can be interpreted as-needed in your class. The below explains the default provided usage options.

### Default filler options
Except when using `options`, the default filler only finds `const StringName` values to fill its list of words. 
Godot supports providing the editor information about your exported variables through `@export_custom`. For this plugin, the desired line is 
```
@export_custom(PROPERTY_HINT_NONE, "keyword:option(s)")
```
(in place of just `@export`) with the following possible keywords:
- `uselist:ListName` - Uses the directory file (see below) to specify all words in files tagged with `LIST=ListName`. Providing simply `uselist:` with an empty parameter should load all const StringNames from all files in the directory.
- `listmember:member_name` - Uses the directory file. A String or StringName `member_name` must exist within the object. When the object is loaded in the editor, the plugin reads the value of this property and uses that value to check the `LIST=` tag in the directory.
- `local` - Ignores the directory file. Loads all constant StringNames defined within the class this object instantiates.
- `options:Option1,Option2,etc` Ignores the directory file. Mimics `@export_enum` (in a way) by loading the explicitly provided comma separated list of strings (does not strip spaces). This does support StringNames, not just Strings.
- `nolist` - Do not use this plugin with this property. (Useful if `always_on` is true.)
- No hint string: If the default filler is called with no hint string (it should not if `always_on` is false), then it will simply load every word it in every file in the directory.

### Directory file with the default filler
Create a directory file that lists paths/uids to scan for valid String(Name)s to place into a "registry" list. (You can right-click desired files in the filesystem and copy either the path or the UID to paste into the directory.) The directory file 
format is one script path per line, optionally the `LIST=ListName` tag, and optionally with comments using `#`.
```
[UID or Path to Script]  [LIST=ListName]  # Everything after the # is ignored.
```
Be sure to set the path to your directory file in the project settings (see below) if using it. 

### StringNames inside arrays
Godot's internal use of the hint string in `@custom_export` passes everything after the first `:` in the hint string for nested data. So, for example 
```
  @export_custom(PROPERTY_HINT_NONE, ":uselist:Tags")
  var tags : Array[StringName] ## list of tags to help characterize object
```
successfully loads all strings associated with `LIST=Tags` 

## Settings 
Settings can be found in `Project Settings > Addons > Inspector String Verification`
- Directory File Path: Path to the file that tells the `StringRegistryFiller` which files to look in. (Or can have any necessary data for custom implementations.) Defaults to the directory in this plugin's example directory.
- Registry Filler Path: Path to the Script file that handles filling the list. Defaults to `ConstStringNameRegistryFiller`. 
- Boolean `show_on_empty` to open filter list even when the line_edit is empty.  (On by default)
- Add option `always_on` to toggle on/off whether by default the plugin should try to work for every string/stringname.
  - When this is on, can use `nolist` hint to prevent a property from triggering the plugin.
  - When this is off, the filler class has a chance to read the `@custom_export` hint string to determine whether or not to run the plug-in.
  - This option is off by default because Strings and StringNames are edited within the engine in so many places that it seems most prudent to only load the plugin in cases where the user specifically desires it, especially given that the user will likely want to use `@export_custom` for finer control is most cases, anyway. Leaving it always on opens up a much greater significance of the plugin causing very problematic behavior in the editor.

## Implementing Custom Fillers
See the documentation in `StringRegistryFiller` for extending this class and see `ConstStringNameRegistryFiller` as an example. The filler class receives the object being edited, the hint_string provided in the custom export and the location of the directory file and may use that as it wishes to create a list. When an empty list is returned, the plugin silently refuses to load. 

## Using with earlier version of Godot.
While this is primarily tested on Godot 4.7, usage with older versions should involve relatively minor changes for those interested. Here are some known issues backporting to earlier versions. These are very minor, but there may be other problems since I have not fully tested it: 
- This plugin uses the `@abstract` annotation introduced in Godot 4.5 for `StringRegistryFiller` which is not strictly needed.
- It uses `Control.custom_maximum_size` introduced in Godot 4.7 which is probably also not strictly needed.
- `_parse_property` has the `int` type specified for the PropertyUsageFlags, which earlier versions expect to be `PropertyUsageFlags` but 4.7 does not complain about. 

## Comments
I *hope* this addon will also demonstrate a nice example of overriding the inspector editor that can guide other creations, but as (at the time of writing) I'm new to editor plugins and don't have substantive feedback, it may be some time before I am sure of that. I always welcome feedback if the code can be improved, ideas or suggestions, or other constructive comments.

## Updates
These below are updates to the plugin since last version (0.1.0) that was submitted to Godot Asset Store. 
I will collect a few updates before resubmitting to store, to avoid spamming.
The above info may not yet be updated to reflect this, since it is considered in-flux until a new version.
- Changed references from `GDSCript` to `Script` to hopefully support C#.
-  Fixed the popup list remaining open when activating an option by waiting a frame to close it, since item activation changes the entry text, re-triggering the popup list open in the same frame. 
- Default handler `ConstStringNameRegistryFiller`: Implemented multiple usage options as specified in the readme, including control over the word lists loaded for a given property by using `@export_custom(...,hint_string,...)` with one of `options`, `local`, `uselist`, or `listmember`. The class  pre-filters the valid strings list to those in the given list (if provided). Sources are associated with a list name by adding a  `LIST=MyList` tag after a string source in the directory file.
- The annotation `@export_custom...` is needed when `always_on` is false, but `@export` can be used if it is true and no sublist is desired. Options for usage are specified in the README and demonstrated in the example resource.  Interpretation of the hint string is left to the filler so that user-defined custom implementations can use it as needed.
- A variety of other minor cleanups and consolidations in the sourcethat don't impact use.

## TODO (Probably)
- Currently, category specification by peer property requires re-opening the object in the inspector. Is it possible to watch that property and update the valid list when it changes? Probably.
- Add code to fix the pop-ups positioning if it goes off-screen or is otherwise problematic.
- Implement X icon when not verified, make icon usage an option.
- Add options for specifying only Strings/StringNames
- Add context menu item to FileSystem to easily add/remove files to/from the directory.
- Decide whether repopulating the list every time a resource is opened will be problematic for very large lists, and there should be an optional behavior change.
- Add option to place list in a scroll container
- Switch to dictionary based on the list of files (or other options?) and add option to include menubutton above control to allow the user to filter to the specific script
