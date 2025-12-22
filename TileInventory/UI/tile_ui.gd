extends Control

@onready var tile_color: ColorRect = $AspectRatioContainer/TileColor
@onready var selected: ColorRect = $AspectRatioContainer/selected

func set_status(status:Color, is_selected:bool=false) -> void:
	tile_color.set_color(status)
	if is_selected:
		selected.show()
	else:
		selected.hide()
