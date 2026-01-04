extends Control

@export_group("Inventory Data")
@export var inventory:TileInventory

@export_group("UI Data")
@onready var grid_container: GridContainer = $GridContainer
@export var tile_res:PackedScene = preload("res://TileInventory/UI/tile_ui.tscn")
@export var empty_color:Color
@export var filled_color:Color

var tile_size:float = 40 + 1
var tile_spacing:Vector2
var ui_cells:Array[Control] = []
var active_icons:Array[ItemImage] = []
var active_stack_texts:Array[Label] = []
signal click_event(location:Vector2i, is_left:bool)

func _ready() -> void:
	SignalBus.tile_ui_changed.connect(on_tile_ui_changed)

func set_tile_size() -> void:
	# set the inventory grid size
	grid_container.set_columns(inventory.w)
	grid_container.set_custom_minimum_size(Vector2(inventory.w * tile_size, inventory.h * tile_size))
	ui_cells = []
	ui_cells.resize(inventory.w * inventory.h)
	for i in inventory.w * inventory.h:
		# setup each tile
		var tmp:Control = tile_res.instantiate()
		ui_cells[i] = tmp
		# set tile index, inventory reference, and connect click event
		tmp.index = i
		tmp.inventory_ref = inventory
		tmp.on_button_pressed.connect(on_click_event)
		# add tile to inventory
		grid_container.add_child(tmp)

func update_item_icons() -> void:
	# clear all current item images and stack numbers
	for n in active_icons:
		n.queue_free()
	for n in active_stack_texts:
		n.queue_free()
	active_icons = []
	active_stack_texts = []
	# add an item image for each item in the inventory
	for i in len(inventory.items):
		var icon:ItemImage = ItemImage.new()
		icon.setup(inventory.items[i].image, i, inventory)
		var item:Item = inventory.items[i]
		var org:Vector2 = Vector2(inventory.items[i].cell_origin) - inventory.items[i].true_origin
		var pos:Vector2 = Vector2(inventory.item_pos[i]) - org
		# add image offset: half image_size + number_of_cell_padding * padding_width
		var c_offset:Vector2 = icon.size / 2 + Vector2(item.h + 1, item.w + 1)
		var icon_scale:Vector2 = Vector2(tile_size/icon.size[0] * item.w , tile_size/icon.size[1] * item.h)
		add_child(icon)
		icon.set_pivot_offset(icon.size/2)
		# check if rotation is any multiple of 90 degrees (second abs is for rot==0)
		if fmod(abs(abs(inventory.items[i].rotation) - 90), 180) < 0.01:
			# flip scale x and y
			icon.set_scale(Vector2(icon_scale[1], icon_scale[0]))
			icon_scale = Vector2(icon_scale[1], icon_scale[0])
		else:
			icon.set_scale(icon_scale)
		icon.set_rotation_degrees(inventory.items[i].rotation)
		# center image to item shape
		var image_pos:Vector2 = Vector2(pos[1] + 0.5, pos[0] + 0.5) * tile_size - c_offset
		icon.set_position(image_pos)
		icon.show()
		active_icons.append(icon)
		# add stack numbers
		var stack_text:Label = Label.new()
		add_child(stack_text)
		stack_text.text = "%d" % [inventory.item_count[i]]
		var image_upper_left:Vector2 = inventory.item_pos[i] - inventory.items[i].cell_origin
		stack_text.position = Vector2(image_upper_left[1] + 1, image_upper_left[0]) * (tile_size) + stack_text.size
		active_stack_texts.append(stack_text)

func update_highlight(selected:Vector2i) -> void:
	# update tile highlight and item icons
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
	click_event.emit(inventory.get_coords(index), is_left)

func on_tile_ui_changed(selected:Vector2i) -> void:
	self.update_highlight(selected)
