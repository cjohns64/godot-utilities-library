class_name Item extends Node

@export var h:int
@export var w:int
@export var shape_str:String
var shape:Array[bool] = []
var debug:bool = true

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
	#print("init shape")
	if len(shape_str) >= w*h:
		for i in (h * w):
			shape.append(shape_str[i] == "1")
	else:
		for i in (h * w):
			shape.append(false)

func get_cell(row:int, col:int) -> bool:
	return shape[row*w + col]

func set_cell(row:int, col:int, data:bool) -> void:
	shape[row*w + col] = data

func _ready():
	self.init_shape()
	self.print_shape()

func _process(delta: float) -> void:
	if debug:
		#print("transpose")
		#self.transpose().print_shape()
		#print("rotate left")
		#self.rotate_left().print_shape()
		#print("rotate right")
		#self.rotate_right().print_shape()
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

func print_shape() -> void:
	for i in h:
		var row:String = ""
		for j in w:
			var val:bool = self.get_cell(i, j)
			if val:
				row = row + "1"
			else:
				row = row + "0"
		print(row)
