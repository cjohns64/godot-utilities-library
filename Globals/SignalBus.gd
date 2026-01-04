extends Node
# global signal bus
# simplify connecting signals across multiple packed scenes, large node trees that are still in development, and uncertain node paths
# place signal or function in the signal bus and connect/call from user node

# signal for requesting a ui update
signal tile_ui_changed(selected:Vector2i)

func _notification(what:int)->void:
	# process notifications
	if what == Node.NOTIFICATION_DRAG_END:
		if not get_viewport().gui_is_drag_successful():
			# drag was ended unsuccessfully -- assume it was a ui update worthy event
			tile_ui_changed.emit(Vector2i.ZERO)
