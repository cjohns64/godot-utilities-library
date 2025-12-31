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
	
#func _get_drag_data(at_position: Vector2) -> Variant:
	#var loc:Vector2i = inventory_ref.get_coords(index)
	#if inventory_ref.get_cell(loc[0], loc[1]):
		## cell is has an item
		## TODO set drag preview
		#return inventory_ref.items[inventory_ref.index_at_pos(loc)]
	#else:
		## no item
		#return
