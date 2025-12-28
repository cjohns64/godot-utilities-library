extends Control

@onready var tile_inventory_ui: Control = $PanelContainer/HBoxContainer/TileInventory_UI
@onready var items: Node = $Items
@onready var mode: OptionButton = $PanelContainer/HBoxContainer/TestInterface/ModeContainer/Mode
@onready var rotation_selection: OptionButton = $PanelContainer/HBoxContainer/TestInterface/RotationContainer/RotationSelection
@onready var shape_options: OptionButton = $PanelContainer/HBoxContainer/TestInterface/ShapeContainer/ShapeOptions

var active_cell:Vector2i = Vector2i.ZERO
var from_cell:Vector2i = Vector2i.ZERO
var item_options:Array[Item] = []
var inventory:TileInventory
var do_once:bool = true

func _ready() -> void:
	tile_inventory_ui.set_tile_size()
	inventory = tile_inventory_ui.inventory
	shape_options.clear()
	for item in items.get_children():
		if item is Item:
			item_options.append(item)
			shape_options.add_item(item.to_string())
	tile_inventory_ui.update_highlight(Vector2i.ZERO)

func add_item(loc:Vector2i) -> void:
	var selected_id:int = shape_options.get_selected_id()
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
	match mode.get_selected_id():
		0: # add/remove
			active_cell = location
			if is_left:
				add_item(location)
			else:
				remove_item(location)
		1: # move
			if is_left:
				active_cell = location
				inventory.try_move(from_cell, active_cell)
			else:
				from_cell = location
			tile_inventory_ui.update_highlight(from_cell)
		_: # rotate
			active_cell = location
			var index:int = inventory.index_at_pos(active_cell)
			if index == -1:
				return # no item to rotate
			# rotate about item origin
			var item_loc:Vector2i = inventory.item_pos[index]
			if is_left:
				inventory.try_move_and_rotate(active_cell, item_loc, 1, true)
			else:
				inventory.try_move_and_rotate(active_cell, item_loc, -1, true)
			tile_inventory_ui.update_highlight(item_loc)


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

func _on_sort_pressed() -> void:
	inventory.sort()
	tile_inventory_ui.update_highlight(from_cell)
