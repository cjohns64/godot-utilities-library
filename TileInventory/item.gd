class_name Item extends Node
# Parent class for Items, intended to be extended by new item classes.
# provides only basic inventory stacking/management operation

# height and width of the item in cells
@export_range(0, 100) var h:int
@export_range(0, 100) var w:int
# item ID, used for uniquely identifying the item
@export var ID:String = "item"
# stacking limits for item
@export_range(1, 999) var max_item_stack:int = 3
@export var item_stacking:bool = true
# string used to initialize the shape
@export var shape_str:String
# matrix representing the shape of the item
var shape:Array[bool] = []
# the logical rotation of the item, used for rotating the item image to match the cell rotation
var rotation:float = 0
# flag for debug code
var debug:bool = true
# cell and true origin
# cell origin is used for all operations based off of the shape of the item
# true origin is used for the item image location
@warning_ignore("integer_division")
@onready var cell_origin:Vector2i = Vector2i(h/2, w/2)
@onready var true_origin:Vector2 = Vector2(float(h)/2.0, float(w)/2.0)
# resource to use for the item image, it will be scaled to fit the item shape
@export var image = preload("res://icon.svg")

# function for determining if two items are equal,
# use this function instead of the '==' operation
func equals(item:Item) -> bool:
	return item.ID == self.ID

# function for copying all metadata associated with the item
# use this function instead of copying data manually, this allows new metadata to be added later
func _copy_metadata(item:Item) -> void:
	self.ID = item.ID
	self.max_item_stack = item.max_item_stack
	self.item_stacking = item.item_stacking
	self.image = item.image
	self.rotation = item.rotation

func _to_string() -> String:
	return self.ID

func _init(_h:int=0, _w:int=0) -> void:
	if _h > 0:
		h = _h
	if _w > 0:
		w = _w
	self.init_shape()

func set_shape(_shape:Array[bool]) -> void:
	shape = _shape

func recalculate_origin() -> void:
	@warning_ignore("integer_division")
	cell_origin = Vector2i((h-1)/2, (w-1)/2)
	true_origin = Vector2(float(h)/2.0, float(w)/2.0)

# function for setting up the item shape
# initializes shape to the shape string if it is defined
# otherwise sets the shape to all empty
func init_shape() -> void:
	# setup item shape matrix
	shape = []
	if len(shape_str) >= w*h:
		for i in (h * w):
			shape.append(shape_str[i] == "1")
	else:
		shape.resize(h * w)
		shape.fill(false)
	recalculate_origin()

func get_cell(row:int, col:int) -> bool:
	return shape[row*w + col]

func set_cell(row:int, col:int, data:bool) -> void:
	shape[row*w + col] = data

func get_abs_offset(rel_offset:Vector2i) -> Vector2i:
	return Vector2i(rel_offset[0] - cell_origin[0], rel_offset[1] - cell_origin[1])

func _ready():
	self.init_shape()

func __transpose() -> Item:
	var new_item = Item.new(w, h) # reversed width and height
	new_item._copy_metadata(self)
	for row in h:
		for col in w:
			new_item.set_cell(col, row, self.get_cell(row, col))
	return new_item

func rotate_left() -> Item:
	var new_item = self.__transpose()
	new_item.rotation = fmod(self.rotation - 90, 360)
	# reverse each col
	for row in int(new_item.h / 2):
		for col in new_item.w:
			# swap values at row, col and h-row, col
			var tmp:bool = new_item.get_cell(row, col)
			new_item.set_cell(row, col, new_item.get_cell(new_item.h - row-1, col))
			new_item.set_cell(new_item.h - row-1, col, tmp)
	return new_item
	
func rotate_right() -> Item:
	var new_item = self.__transpose()
	new_item.rotation = fmod(self.rotation + 90, 360)
	# reverse each row
	for row in new_item.h:
		for col in int(new_item.w / 2):
			# swap values at row, col and h-row, col
			var tmp:bool = new_item.get_cell(row, col)
			new_item.set_cell(row, col, new_item.get_cell(row, new_item.w - col - 1))
			new_item.set_cell(row, new_item.w - col - 1, tmp)
	return new_item

func __find_extent() -> Vector4i:
	var min_r:int = 2*h
	var max_r:int = 0
	var min_c:int = 2*w
	var max_c:int = 0
	for i in h:
		for j in w:
			# check if cell has a value
			if self.get_cell(i, j):
				# update min row and col
				if min_r > i:
					min_r = i
				if min_c > j:
					min_c = j
				# update max row and col
				if max_r < i:
					max_r = i
				if max_c < j:
					max_c = j
	return Vector4i(min_r, max_r, min_c, max_c)

func trim_to_extent() -> void:
	var extent:Vector4i = self.__find_extent()
	var new_shape:Array[bool] = []
	var rows:int = extent[1] - extent[0]+1
	var cols:int = extent[3] - extent[2]+1
	if rows == h and cols == w:
		return # no change needed
	new_shape.resize(rows * cols)
	# copy values
	for i in rows:
		for j in cols:
			new_shape[i*cols + j] = self.shape[(i + extent[0])*w + j + extent[2]]
	self.shape = new_shape
	self.h = rows
	self.w = cols
	recalculate_origin()
	print("trim complete:")
	self.print_shape()

func print_shape() -> void:
	print("cell origin: ", cell_origin, " true origin: ", true_origin)
	for i in h:
		var row:String = ""
		for j in w:
			var val:bool = self.get_cell(i, j)
			if val:
				row = row + "1"
			else:
				row = row + "0"
		print(row)
