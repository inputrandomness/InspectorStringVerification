# Inspector String Verification
A Godot inspector plugin for verifying that `Strings` or `Stringnames` typed into exported resource properties in the inspector are contained a list of strings considered valid. 

## Usage and Behavior
This is written for the last tagged version; if pulling latest commits from repo, see "Updates" below as well.

Create a directory file that lists paths/uids to scan for valid String(Name)s to place into a registry (okay it's just an array). (You can right-click desired files in the filesystem and copy either the path or the UID to paste into the directory.) Set the path to this directory in the project settings (see below). Optionally, implement a custom scanner by extending `StringRegistryFiller` as desired, in which case the directory file may contain whatever data is expected by your scanner. 

When editing a resource in the inspector with exported `Strings` or `StringNames`, this add-on opens a live-filtered dropdown list in a popup panel for viewing matching names from the registry and shows a verification checkmark when the value in the property is in the registry. 

Live-filtering is through an `ItemList` in a `PanelContainer` on a high-valued `CanvasLayer`, and the popup currently does not adjust if it goes off-screen. In most cases, that is not a problem, but that is planned future work.

The current default implementation uses a directory file with a list of paths/uids for `GDSCript` files and pulls all (and only) `const StringNames` defined within those files. This behavior is easily modified with a custom class extending `StringRegistryFiller` and implementing `get_list(filename)`.

The list is repopulated whenever a resource is opened in the inspector, so you don't have to do anything special if you change the directory.

## Settings 
Settings can be found in `Project Settings > Addons > Inspector String Verification`
- Directory File Path: Path to the file that tells the `StringRegistryFiller` which files to look in. (Or can have any necessary data for custom implementations.)
- Registry Filler Path: Path to the source 

## Comments
I *hope* this addon will also demonstrate a nice example of overriding the inspector editor that can guide other creations, but as (at the time of writing) I'm new to editor plugins and don't have substantive feedback, it may be some time before I am sure of that. I always welcome feedback if the code can be improved, ideas or suggestions, or other constructive comments.

## Updates
These are commits to repo since last version (0.1.0) that was submitted to Godot Asset Store. 
I will collect a few updates before resubmitting to store, to avoid spamming.
The above usage is not yet updated to reflect this, since it is considered in-flux until a new version.
- Fixed the popup list remaining open when activating an option by waiting a frame to close it, since item activation changes the entry text, re-triggering the popup list open in the same frame. 
- Implemented categories as specified below, with `ConstStringNameRegistryFiller` pre-filtering the valid strings list to those in the given category if a category is provided, and ignoring categories if none is provided (i.e., it will accept all StringNames found). StringName sources are categorized by adding a  `CATEGORY=MyCategory` tag after a string source in the directory file. (NOTE: A custom handler implementation can handle this however it wants.
- `StringRegistryFiller` now uses signature `get_registry(path_to_directory, category) -> Array[String]`
- Add option `show_on_empty` to open filter list even when the line_edit is empty.
- Add option `always_on` to toggle on/off whether by default the plugin should try to work for every string/stringname.
  - When this is on, can use `nolist` hint to prevent a property from triggering the plugin
  - When this is off, can use (see below) `literal:..` and `property:..` to tell the plugin how to use it, with `'literal:'` (empty category) to turn it on with no category. 
- Use `@export_custom(...,hint_string,...)` to allow user to supply category and usage information on a per-property basis by setting value of `hint_string`. This is needed when `always_on` is false, but `@export` can be used if it is true and no category is desired. 
  - `"literal:category_name"` (categories) tells the plugin this property should only use strings from `category_name`
  - `"property:member_name"` (categories) tells the plugin this property should onyl use strings in the category stored in `member_name`
  - `nolist` tells
- Included test cases in the example resource that illustrate usage of custom_export, options, and categories.
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
