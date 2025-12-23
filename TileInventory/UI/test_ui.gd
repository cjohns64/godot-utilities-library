extends Control

@onready var tile_inventory_ui: Control = $PanelContainer/HBoxContainer/TileInventory_UI
@onready var items: Node = $Items
@onready var item_option_button: OptionButton = $PanelContainer/HBoxContainer/Test_interface_container/HBoxContainer2/OptionButton
@onready var rotation_selection: OptionButton = $PanelContainer/HBoxContainer/Test_interface_container/HBoxContainer/RotationSelection
@onready var move_mode_button: CheckButton = $PanelContainer/HBoxContainer/Test_interface_container/MoveModeButton

var active_cell:Vector2i = Vector2i.ZERO
var from_cell:Vector2i = Vector2i.ZERO
var item_options:Array[Item] = []
var inventory:TileInventory
var do_once:bool = true

func _ready() -> void:
	tile_inventory_ui.set_tile_size()
	inventory = tile_inventory_ui.inventory
	item_option_button.clear()
	for item in items.get_children():
		if item is Item:
			item_options.append(item)
			item_option_button.add_item(item.to_string())
	tile_inventory_ui.update_highlight(Vector2i.ZERO)

func add_item(loc:Vector2i) -> void:
	var selected_id:int = item_option_button.get_selected_id()
	if selected_id == -1:
		selected_id = 0
	var item:Item = item_options[selected_id]
	match rotation_selection.get_selected_id():
		1:
			# left
			item = item.rotate_left()
		2:
			# right
			item = item.rotate_right()
		3:
			# down
			item = item.rotate_left().rotate_left()
		_:
			pass
	inventory.check_add(loc, item)
	tile_inventory_ui.update_highlight(from_cell)

func remove_item(loc:Vector2i) -> void:
	inventory.remove_item_by_cell(loc[0], loc[1])
	tile_inventory_ui.update_highlight(from_cell)

func _on_button_pressed() -> void:
	tile_inventory_ui.update_highlight(from_cell)

func _on_tile_inventory_ui_click_event(location: Vector2i, is_left: bool) -> void:
	if move_mode_button.is_pressed():
		# move mode
		if is_left:
			active_cell = location
			inventory.try_move(from_cell, active_cell)
			tile_inventory_ui.update_highlight(from_cell)
		else:
			from_cell = location
			tile_inventory_ui.update_highlight(from_cell)
	else:
		active_cell = location
		if is_left:
			add_item(location)
		else:
			remove_item(location)

func looping_range(value:int, max_value:int, d:int) -> int:
	var tmp:int = value + d
	if tmp >= max_value:
		return tmp % max_value
	elif tmp < 0:
		return max_value + (tmp % max_value)
	return tmp

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Rotation Up"):
		print("rotation select ++")
		rotation_selection.select(looping_range(rotation_selection.selected, rotation_selection.item_count, 1))
	if Input.is_action_just_pressed("Rotation Down"):
		print("rotation select --")
		rotation_selection.select(looping_range(rotation_selection.selected, rotation_selection.item_count, -1))
