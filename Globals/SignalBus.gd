extends Node

signal tile_ui_changed(selected:Vector2i)

func _notification(what:int)->void:
	if what == Node.NOTIFICATION_DRAG_END:
		if not get_viewport().gui_is_drag_successful():
			# drag failed update ui
			tile_ui_changed.emit(Vector2i.ZERO)
