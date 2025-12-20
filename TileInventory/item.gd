class_name Item extends Node

@export_range(0, 100) var h:int
@export_range(0, 100) var w:int
@export var shape_str:String
var shape:Array[bool] = []
var debug:bool = true
@warning_ignore("integer_division")
@onready var origin:Vector2i = Vector2i(w/2, h/2)

func _init(_h:int=0, _w:int=0) -> void:
	if _h > 0:
		h = _h
	if _w > 0:
		w = _w
	self.init_shape()

func set_shape(_shape:Array[bool]) -> void:
	shape = _shape

func init_shape() -> void:
	# setup item shape matrix
	shape = []
	if len(shape_str) >= w*h:
		for i in (h * w):
			shape.append(shape_str[i] == "1")
	else:
		for i in (h * w):
			shape.append(false)
	# recalculate origin
	@warning_ignore("integer_division")
	origin = Vector2i(w/2, h/2)

func get_cell(row:int, col:int) -> bool:
	return shape[row*w + col]

func set_cell(row:int, col:int, data:bool) -> void:
	shape[row*w + col] = data

func _ready():
	self.init_shape()
	self.print_shape()

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if debug:
		#print("item base")
		#self.print_shape()
		#print("transpose")
		#self.transpose().print_shape()
		#print("rotate left")
		#self.rotate_left().print_shape()
		#print("rotate right")
		#self.rotate_right().print_shape()
		#print("Extent")
		#print(self.find_extent())
		debug = false

func transpose() -> Item:
	var new_item = Item.new(w, h) # reversed width and hieght
	var new_shape:Array[bool] = []
	for i in h*w:
		new_shape.append(false)
	for row in h:
		for col in w:
			new_item.set_cell(col, row, self.get_cell(row, col))
	return new_item

func rotate_left() -> Item:
	var new_item = self.transpose()
	# reverse each col
	for row in int(new_item.h / 2):
		for col in new_item.w:
			# swap values at row, col and h-row, col
			var tmp:bool = new_item.get_cell(row, col)
			new_item.set_cell(row, col, new_item.get_cell(new_item.h - row-1, col))
			new_item.set_cell(new_item.h - row-1, col, tmp)
	return new_item
	
func rotate_right() -> Item:
	var new_item = self.transpose()
	# reverse each row
	for row in new_item.h:
		for col in int(new_item.w / 2):
			# swap values at row, col and h-row, col
			var tmp:bool = new_item.get_cell(row, col)
			new_item.set_cell(row, col, new_item.get_cell(row, new_item.w - col - 1))
			new_item.set_cell(row, new_item.w - col - 1, tmp)
	return new_item

func find_extent() -> Vector4i:
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

func print_shape() -> void:
	print(origin)
	for i in h:
		var row:String = ""
		for j in w:
			var val:bool = self.get_cell(i, j)
			if val:
				row = row + "1"
			else:
				row = row + "0"
		print(row)
