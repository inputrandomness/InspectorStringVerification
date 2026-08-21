# Inspector String Verification
A Godot inspector plugin for verifying that `Strings` or `Stringnames` typed into exported resource properties in the inspector are contained a list of strings considered valid. 

## Usage and Behavior
Create a directory file that lists paths/uids to scan for valid String(Name)s to place into a registry (okay it's just an array). (You can right-click desired files in the filesystem and copy either the path or the UID.) Set the path to this directory in the project settings (see below). Optionally, implement a custom scanner by extending `StringRegistryFiller` as desired, in which case the directory file may contain whatever data is expected by your scanner. 

When editing a resource in the inspector with exported `Strings` or `StringNames`, this add-on opens a live-filtered dropdown list in a popup panel for viewing matching names from the registry and shows a verification checkmark when the value in the property is in the registry. 

Live-filtering is through an `ItemList` in a `PanelContainer` on a high-valued `CanvasLayer`, and the popup currently does not adjust if it goes off-screen. Hopefully that will be updated in the future.

Current default implementation uses directory file with a list of paths/uids for `GDSCript` files and pulls all (and only) `const StringNames` defined within those files. This behavior is easily modified with a custom class extending `StringRegistryFiller` and implementing `get_list(filename)`.

The list is repopulated whenever a resource is opened in the inspector, so you don't have to do anything special if you change the directory.

## Settings 
Settings can be found in `Project Settings > Addons > Inspector String Verification`
- Directory File Path: Path to the file that tells the `StringRegistryFiller` which files to look in. (Or can have any necessary data for custom implementations.)
- Registry Filler Path: Path to the source 

## TODO
- Add code to fix the pop-ups positioning if it goes off-screen or is otherwise problematic.
- Implement X icon when not verified, make icon usage an option.
- Add options for specifying only Strings/StringNames
- Add context menu item to FileSystem to easily add/remove files to/from the directory.
- Decide whether repopulating the list every time a resource is opened will be problematic for very large lists, and there should be an optional behavior change.
- Add option to open filter list even when the line_edit is empty.
- Add option to place list in a scroll container
- Switch to dictionary based on the list of files (or other options?) and add option to include menubutton above control to allow the user to filter to the specific script
