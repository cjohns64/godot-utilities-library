class_name ItemImage extends TextureRect

var item_index:int
var inv:TileInventory

func setup(_texture:Texture, _index:int, _inventory:TileInventory) -> void:
	self.texture = _texture
	self.set_size(_texture.get_size())
	self.item_index = _index
	self.inv = _inventory

func _get_drag_data(at_position: Vector2) -> Variant:
	print("drag started at ", at_position, " index: ", self.item_index)
	if item_index >= 0 and item_index < len(inv.items):
		# valid index
		var c:Control = Control.new()
		var preview:TextureRect = self.duplicate()
		c.add_child(preview)
		c.set_position(Vector2.ZERO)
		preview.set_position(preview.size * -0.5)
		set_drag_preview(c)
		self.hide()
		return self
	else:
		return

# for dropping on an item image
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data is ItemImage:
		# check if types match
		if inv.items[self.item_index].equals(inv.items[data.item_index]):
			# check if destination stack can recive the dragging stack
			if inv.check_stacking(self.item_index, inv.item_count[data.item_index]):
				return true
	return false

# processing drops on item images
func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is ItemImage:
		# item does not move unless it can
		print("image drop:: attpmpting move from ", inv.item_pos[data.item_index], " to ", inv.item_pos[self.item_index])
		var dropped:bool = inv.try_move_index(data.item_index, inv.item_pos[self.item_index])
		data.show()
