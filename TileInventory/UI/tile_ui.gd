extends Control
# single tile UI element, driven by the tile-inventory system and sends updates to the inventory system
# Does not own any data related to the inventory function

@onready var tile_color: ColorRect = $AspectRatioContainer/TileColor
@onready var selected: ColorRect = $AspectRatioContainer/selected
var index:int = 0 # index of this tile, set by tile-inventory-ui
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

# Enable dropping of ItemImage drag-and-drops on empty/full tiles
# Does not handle dropping ItemImages on other ItemImages
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data is ItemImage:
		# _drop_data will check if move is allowed
		return true
	return false
	
# Process dropped ItemImage drag-and-drops on tiles
func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is ItemImage:
		# item does not move unless it can
		print("Tile drop:: attempting move from ", inventory_ref.item_pos[data.item_index], " to ", inventory_ref.get_coords(index))
		var dropped:bool = inventory_ref.try_move_index(data.item_index, inventory_ref.get_coords(index))
		data.show()
