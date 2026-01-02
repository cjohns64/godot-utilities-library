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
		return self
	else:
		return
