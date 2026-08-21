class_name StringVerifyEditorProperty
extends EditorProperty

## A custom controls for editing a [String] or [StringName] property.
##
## Uses a custom [LineEdit] and [ItemList] popup / dropdown list, which shows on a [CanvasLayer],
## as well as showing a checkmark icon when the value of the string in the line 
## editor is found in the registry.[br][br]
## 
## The registry is setup by a combination of a "directory" file and a script
## implementing [StringRegistryFiller] which are set in 
## Project Settings > Addons > Inspector String Verification.

const DROPDOWN_STYLEBOX = preload("uid://dbjmr8vf0s72j")
const DROPDOWN_Y_MARGIN = 4

var line_edit := LineEdit.new()
var popup_layer := CanvasLayer.new()
var menu_panel := PanelContainer.new()
var menu := ItemList.new()
var check_icon := TextureRect.new()

var directory_path : String
var registry_filler : StringRegistryFiller

var registry : Array[String]
var current_value : String
var updating = false  # Used to avoid making changed while the property is being updated.
var dropdown_open : bool = false ## For some reason menul_panel.visible is false even when I can see it.
var last_selected = -1

var _debug: bool = false # For crazy printing when things go wrong

# Virtual Overrides

func _init():
	
	var script := load(InspectorStringVerificationEditorPlugin.registry_filler_uid) as GDScript
	if not script:
		printerr("Failed to load StringRegistryFiller script at " + InspectorStringVerificationEditorPlugin.registry_filler_uid)
		return
	registry_filler = script.new()
	directory_path = InspectorStringVerificationEditorPlugin.registry_directory_path
	
	print("["+get_edited_property()+"]"+"Initializing propery editor.")
	add_child(line_edit)
	add_focusable(line_edit)
	
	add_child(popup_layer)
	popup_layer.add_child(menu_panel)
	line_edit.add_child(check_icon)
	menu_panel.add_child(menu)
	add_focusable(menu)
	
	menu_panel.add_theme_stylebox_override("panel", DROPDOWN_STYLEBOX) 
	
	popup_layer.layer = RenderingServer.CANVAS_LAYER_MAX-1
	
	menu.visible = true
	close_dropdown()
	
	menu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	refresh_control_text()
	line_edit.text_changed.connect(_on_text_changed)
	menu.item_activated.connect(_on_item_clicked)
	line_edit.focus_exited.connect(_on_control_lost_focus)
	menu.focus_exited.connect(_on_control_lost_focus)
	
	check_icon.texture = EditorInterface.get_editor_theme().get_icon("ImportCheck", "EditorIcons")
	check_icon.visible = false
	
	registry = registry_filler.get_list(directory_path)
	
# Methods 

## Called when updating the control to synch the value of the property. Also, 
## refreshes status of verified icon.
func refresh_control_text():
	var caret_pos = line_edit.caret_column
	line_edit.text = current_value
	line_edit.caret_column = caret_pos
	check_icon.visible = can_show_verification()
	set_check_position.call_deferred() # call here since things can move


## True if we should be showing the verified icon
func can_show_verification() -> bool:
	return check_icon.texture and line_edit.text in registry


## Open the dropdown box. TODO This may not be necessary, as dropdown_open
## should not be needed for tracking status, but I was finding my way through
## making a plugin. And maybe this will have other benefits later
func open_dropdown() -> void:
	menu_panel.show()
	dropdown_open = true


## Close the dropdown box.
func close_dropdown() -> void:
	menu_panel.hide()
	dropdown_open = false


## Reactivate and focus on the editor, position caret cleanly
func revert_to_editor() -> void:
	line_edit.grab_focus()
	line_edit.edit()
	line_edit.caret_column = line_edit.text.length()


## Select an item in the list and track that it was selected.
func force_select(idx : int) -> void:
	menu.select(idx)
	last_selected = get_selected_item()


## Determine which item is selected in ItemList
func get_selected_item()-> int:
	var selection = menu.get_selected_items()
	if selection.size() > 0:
		return selection[0]
	else: 
		return 0  # TODO Should this be -1?


## Place the checkmark icon at the end of the edit box.
func set_check_position() -> void:
	if not (check_icon and check_icon.texture): 
		return
	var line_rect := line_edit.get_global_rect()
	check_icon.global_position = Vector2(line_rect.end.x - check_icon.texture.get_size().x, 
				line_rect.position.y)

# Signal Handlers

## Called when the line_editor text changes. Opens and populates list, or closes it. 
## Also triggers check mark if current value is verified.
func _on_text_changed(new_text : String):
	if updating:
		return
	
	var value = new_text.strip_edges()
	emit_changed(get_edited_property(), value)
	var items = registry.filter(func (s : String): return s.begins_with(value) )
	items.sort()
	
	menu.clear()
	if _debug: print("Value is '" + value + "' and item size is " + str(items.size()))
	
	## These may not be necessary, but in case things get moved around.
	var line_rect := line_edit.get_global_rect()
	
	check_icon.global_position = Vector2(line_rect.end.x - check_icon.texture.get_size().x, 
				line_rect.position.y)
				
	check_icon.visible = can_show_verification()
	
	if value == "" or items.size() == 0:
		close_dropdown()
	elif line_edit.has_focus():
		
		var pos = Vector2(line_rect.position.x-12, line_rect.end.y)
		var font = line_edit.get_theme_font("font")
		var font_size = line_edit.get_theme_font_size("font_size")
		var min_popup_size = Vector2(line_rect.size.x, DROPDOWN_Y_MARGIN)
		var e_s = EditorInterface.get_editor_scale()
		for item in items:
			menu.add_item(item)
			var sz = font.get_string_size(item, HORIZONTAL_ALIGNMENT_LEFT, -1 , font_size)
			if _debug: print("Size for " + item + " is " + str(sz))
			min_popup_size.x = max(sz.x, min_popup_size.x)
			min_popup_size.y += (DROPDOWN_Y_MARGIN+ sz.y)*e_s
		
		menu.custom_minimum_size = min_popup_size
		menu_panel.custom_maximum_size = menu.custom_minimum_size
		menu_panel.custom_minimum_size = menu.custom_minimum_size
		menu_panel.reset_size()
		await get_tree().process_frame
		
		if _debug: print("Using menu size: " + str(menu_panel.size) + ", custom was: " + str(menu.custom_minimum_size))
				
		var popup_rect = Rect2i(pos, menu.custom_minimum_size)
		
		## TODO Adjust window position so it does not go off-screen when large
		#var vp_rect = line_edit.get_viewport_rect()
		#var shift_x : float = min(0, vp_rect.end.x - popup_rect.end.x)
		#var above : bool = (popup_rect.end.y > vp_rect.end.y)
		#var new_x = popup_rect.position.x + shift_x
		#var new_y = popup_rect.position.y - min_popup_size.y - line_rect.size.y 

		menu_panel.set_position(pos)
		force_select(0)
		open_dropdown()
		if _debug: print("Popping up at " + str(popup_rect) + ". LineEdit rect is " + str(line_rect) + ". Dropdown is " + str(dropdown_open) )
	else:
		if _debug: print("Line edit does not have focus.")

## Called when an item in the filter list is clicked on
func _on_item_clicked(idx : int) -> void:
	if updating:
		return
		
	if _debug: print("Item clicked: " + current_value)
	current_value = menu.get_item_text(idx)
	refresh_control_text()
	revert_to_editor()
	emit_changed(get_edited_property(), current_value)
	close_dropdown()

## Part of the plugin structure, needed to update the property whenever it has changed
func _update_property():
	var new_value = get_edited_object()[get_edited_property()]
	if (new_value == current_value):
		return

	updating = true
	current_value = new_value
	refresh_control_text()
	updating = false


## This is received when editing the property with the LineEdit, but see [method _input] below.
func _unhandled_key_input(event: InputEvent) -> void:
	if event.keycode == KEY_ESCAPE: # Emergency escape hatch.
		var was_open := dropdown_open
		close_dropdown()
		if was_open:
			revert_to_editor()
			get_viewport().set_input_as_handled()


	# If multiple properties use this editor, EVERY ONE OF THEM 
	# will get this, so only respond if our specific controls are in focus.
	if not line_edit.has_focus() or menu.has_focus():
		return 
		
	if event is InputEventKey:
		var handled := true
		event = event as InputEventKey
		if event.keycode == KEY_DOWN and dropdown_open:
				if _debug: print("Going from lineedit to menu")
				menu.grab_focus()
				force_select(0)
		if event.keycode == KEY_ENTER and line_edit.has_focus():
			close_dropdown()
		else: handled = false
		if handled: get_viewport().set_input_as_handled()


## When the popup menu opens, the PropertyEditor will no longer receive unhandled key input.
## So for custom key properties while navigating the list, we need to implement them here.
## The list's standard input does happen, so we also track where we had been in [member last_selected].
## Maybe using a custom class inheriting ItemList and overriding [member _unhandled_input] there would
## be cleaner if that works.
func _input(event : InputEvent) ->void:
	if not menu.has_focus():
		return
		
	event = event as InputEventKey
	if not event:
		return
	
	var handled := true
	var selections := menu.get_selected_items()
	if event.keycode == KEY_UP and last_selected == 0:
			if _debug: print("Going from menu to line_edit")
			revert_to_editor()
	elif event.keycode == KEY_DOWN and last_selected == menu.item_count - 1:
			if _debug: print("Cycling menu")
			force_select(0)
	else:
		handled = false
	if handled: get_viewport().set_input_as_handled()
	
	last_selected = get_selected_item()


## If we lose focus from both controls and a frame has gone by, make sure we close the 
## popup panel.
func _on_control_lost_focus() -> void:
	if not (line_edit.has_focus() or menu.has_focus()):
		await get_tree().process_frame
		if not (line_edit.has_focus() or menu.has_focus()):
			close_dropdown()
