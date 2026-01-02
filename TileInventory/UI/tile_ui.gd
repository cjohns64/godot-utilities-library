extends Control

@onready var tile_color: ColorRect = $AspectRatioContainer/TileColor
@onready var selected: ColorRect = $AspectRatioContainer/selected
var index:int = 0
var inventory_ref:TileInventory
signal on_button_pressed(index:int, is_left:bool)

func set_status(status:Color, is_selected:bool=false) -> void:
	tile_color.set_color(status)
	if is_selected:
		selected.show()
	else:
		selected.hide()

func _on_add_button_pressed() -> void:
	on_button_pressed.emit(index, true)

func _on_remove_button_pressed() -> void:
	on_button_pressed.emit(index, false)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data is ItemImage:
		var loc:Vector2i = inventory_ref.get_coords(index)
		# TODO remove item first
		#if inventory_ref.check(loc, inventory_ref.items[data.item_index]):
		return true
	return false
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is ItemImage:
		print("attpmpting move from ", data.item_index, " to loc ", inventory_ref.get_coords(index))
		inventory_ref.try_move_index(data.item_index, inventory_ref.get_coords(index))
