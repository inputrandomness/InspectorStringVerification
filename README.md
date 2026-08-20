# InspectorStringVerification
A godot inspector plugin for verifying strings or stringnames typed into the inspector, providing a live-filtered dropdown and verification mark.

Live-filtering is through an ItemList in a PanelContainer on a high-valued CanvasLayer, and the popup currently does not adjust if it goes off-screen. Hopefully that will be updated in the future.

To fill the registry as you need it, write code to pull Strings or StringNames into an array provided by StringRegistry or a class inheriting it. The current version of StringRegistry uses "directory.txt" to list uids or paths for GDSCript files and only pulls const StringNames defined within those files, but this is easily modified as needed.
