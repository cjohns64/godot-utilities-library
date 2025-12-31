extends Control

@export_group("Inventory Data")
@export var inventory:TileInventory
@export_group("UI Data")
@onready var grid_container: GridContainer = $PanelContainer/GridContainer
@export var tile_res:PackedScene = preload("res://TileInventory/UI/tile_ui.tscn")
var tile_size:float = 40
var ui_cells:Array[Control] = []
var active_icons:Array[Control] = []
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
		tmp.inventory_ref = inventory
		tmp.on_button_pressed.connect(on_click_event)
		grid_container.add_child(tmp)

func update_item_icons() -> void:
	for n in active_icons:
		n.queue_free()
	active_icons = []
	for i in len(inventory.items):
		var icon:Control = inventory.items[i].icon.duplicate()
		var item:Item = inventory.items[i]
		var org:Vector2 = Vector2(inventory.items[i].cell_origin) - inventory.items[i].true_origin
		var pos:Vector2 = inventory.item_pos[i]
		var c_offset:Vector2 = icon.size / 2
		var icon_scale:Vector2 = Vector2(tile_size/icon.size[0] * item.w, tile_size/icon.size[1] * item.h)
		add_child(icon)
		icon.set_pivot_offset(icon.size/2)
		# check if rotation is any multiple of 90 degrees (second abs is for rot==0)
		if fmod(abs(abs(inventory.items[i].rotation) - 90), 180) < 0.01:
			# flip scale x and y
			icon.set_scale(Vector2(icon_scale[1], icon_scale[0]))
		else:
			icon.set_scale(icon_scale)
		icon.set_rotation_degrees(inventory.items[i].rotation)
		icon.set_position(Vector2(pos[1] - org[1] + 0.5, pos[0] - org[0] + 0.5) * tile_size - c_offset) #TODO
		icon.show()
		active_icons.append(icon)

func update_highlight(selected:Vector2i) -> void:
	update_item_icons()
	# update tile highlight
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
