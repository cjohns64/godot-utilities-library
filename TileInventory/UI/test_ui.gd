extends Control

@onready var tile_inventory_ui: Control = $PanelContainer/HBoxContainer/TileInventory_UI
@onready var x_offset_input: SpinBox = $PanelContainer/HBoxContainer/Test_interface_container/XOffsetContainer/XOffsetInput
@onready var y_offset_input: SpinBox = $PanelContainer/HBoxContainer/Test_interface_container/YOffsetContainer/YOffsetInput
@onready var items: Node = $Items
@onready var item_option_button: OptionButton = $PanelContainer/HBoxContainer/Test_interface_container/OptionButton

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

func _on_button_pressed() -> void:
	tile_inventory_ui.update_highlight(Vector2i(x_offset_input.value, y_offset_input.value))

func _on_add_item_pressed() -> void:
	var selected_id:int = item_option_button.get_selected_id()
	if selected_id == -1:
		selected_id = 0
	inventory.check_add(Vector2i(x_offset_input.value, y_offset_input.value), item_options[selected_id])
	tile_inventory_ui.update_highlight(Vector2i(x_offset_input.value, y_offset_input.value))

func _on_remove_item_pressed() -> void:
	inventory.remove_item_by_cell(x_offset_input.value, y_offset_input.value)
	tile_inventory_ui.update_highlight(Vector2i(x_offset_input.value, y_offset_input.value))

func _on_offset_input_value_changed(value: float) -> void:
	tile_inventory_ui.update_highlight(Vector2i(x_offset_input.value, y_offset_input.value))
