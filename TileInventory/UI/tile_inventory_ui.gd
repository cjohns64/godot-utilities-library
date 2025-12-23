extends Control

@export_group("Inventory Data")
@export var inventory:TileInventory
@export_group("UI Data")
@onready var grid_container: GridContainer = $PanelContainer/GridContainer
@export var tile_res:PackedScene = preload("res://TileInventory/UI/tile_ui.tscn")
var tile_size:float = 40
var ui_cells:Array[Control] = []
@export var empty_color:Color
@export var filled_color:Color
signal click_event(location:Vector2i, is_left:bool)

func set_tile_size() -> void:
	grid_container.set_columns(inventory.w)
	grid_container.set_custom_minimum_size(Vector2(inventory.w * tile_size, inventory.h * tile_size))
	print("ui column update (set, current) ", inventory.w, " ", grid_container.get_columns())
	ui_cells = []
	ui_cells.resize(inventory.w * inventory.h)
	for i in inventory.w * inventory.h:
		var tmp:Control = tile_res.instantiate()
		ui_cells[i] = tmp
		tmp.index = i
		tmp.on_button_pressed.connect(on_click_event)
		grid_container.add_child(tmp)

func update_highlight(selected:Vector2i) -> void:
	for row in inventory.h:
		for col in inventory.w:
			var is_selected:bool = row == selected[0] and col == selected[1]
			if inventory.get_cell(row, col):
				ui_cells[row*inventory.w + col].set_status(filled_color, is_selected)
			else:
				ui_cells[row*inventory.w + col].set_status(empty_color, is_selected)

func on_click_event(index:int, is_left:bool) -> void:
	var col:int = index % inventory.w
	var row:int = index / inventory.w
	print("click event at ", row, " ", col, " ", is_left)
	click_event.emit(Vector2i(row, col), is_left)
