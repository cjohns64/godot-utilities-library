class_name TileInventory extends Node

@export_range(0, 200) var h:int
@export_range(0, 200) var w:int
@export_range(1, 999) var max_inv_stack:int = 5
@export var inv_stacking:bool = true
var fill_tiles:Array[bool] = []
var items:Array[Item] = []
var item_pos:Array[Vector2i] = []
var item_count:Array[int] = []
var debug:bool = true

func _init(_h:int=0, _w:int=0) -> void:
	if _h > 0:
		h = _h
	if _w > 0:
		w = _w
	self.init_fill()

func set_fill(_fill:Array[bool]) -> void:
	fill_tiles = _fill

func add_to_fill(offset:Vector2i, item:Item) -> void:
	self.__add_or_remove_to_fill(offset, item, true)

func remove_from_fill(offset:Vector2i, item:Item) -> void:
	self.__add_or_remove_to_fill(offset, item, false)

func __add_or_remove_to_fill(offset:Vector2i, item:Item, add:bool=true) -> void:
	var extent:Vector4i = item.find_extent()
	for row in range(extent[0], extent[1]+1):
		for col in range(extent[2], extent[3]+1):
			# map item local coords to inventory coords
			if item.get_cell(row, col):
				self.try_set_cell(row + offset[0], col + offset[1], add)

func init_fill() -> void:
	# setup item fill matrix
	#print("init fill")
	for i in (h * w):
		fill_tiles.append(false)

func get_cell(row:int, col:int) -> bool:
	return fill_tiles[row*w + col]

func try_set_cell(row:int, col:int, data:bool) -> bool:
	if row < h and col < w and row >= 0 and col >= 0:
		self.set_cell(row, col, data)
		return true
	return false

func set_cell(row:int, col:int, data:bool) -> void:
	fill_tiles[row*w + col] = data

func _ready():
	self.init_fill()

func index_at_pos(row:int, col:int) -> int:
	for i in len(items):
		# check if row and col is active in item i
		var r:int = row - item_pos[i][0]
		var c:int = col - item_pos[i][1]
		if r >= items[i].h or r < 0 or c >= items[i].w or c < 0:
			continue # invaild
		elif items[i].get_cell(r, c):
			return i # match
	return -1 # didn't find a match

func find_item_index(item:Item) -> int:
	for i in len(items):
		if items[i].equals(item):
			return i
	return -1 # did not find item

func __is_stacking_enabled(item_index:int) -> bool:
	# check if the item_index is valid
	if item_index == -1 or item_index > len(self.items):
		return false
	# return if stacking is enabled
	return self.inv_stacking and self.items[item_index].item_stacking

func __check_stacking_limit(item_index:int) -> bool:
	# return if the new item stack is under the limit
	var limit:int = mini(self.items[item_index].max_item_stack, self.max_inv_stack)
	return self.item_count[item_index] + 1 <= limit

func check_stacking(item_index:int) -> bool:
	# check if stacking is enabled
	if __is_stacking_enabled(item_index):
		# return if the new item stack is under the limit
		return __check_stacking_limit(item_index)
	return false

# checks if item can be placed at offset, but does not place it
func check(offset:Vector2i, item:Item) -> bool:
	var extent:Vector4i = item.find_extent()
	var item_index:int = self.find_item_index(item)
	# check extent is within inventory
	if offset[0] + extent[1] >= h or offset[1] + extent[3] >= w:
		return false # extent passes end of inventory
	if offset[0] + extent[0] < 0 or offset[1] + extent[2] < 0:
		return false # extent under min
	for row in range(extent[0], extent[1]+1):
		for col in range(extent[2], extent[3]+1):
			# check if stacking is allowed
			if __is_stacking_enabled(item_index):
				# stacking is allowed
				# only allow overlap with the same item type
				var target_index:int = self.index_at_pos(row + offset[0], col + offset[1])
				if target_index == -1:
					# empty tile
					pass # does not affect check result
				elif (target_index == item_index and __check_stacking_limit(item_index)):
					# a same item overlap does not need to overlap perfectly
					# new item will be placed at location of existing item
					return true # overlap and passed conditions
				else:
					return false # at least one tile will conflict
			else:
				# no stacking, just check if the tile is occupied
				if self.get_cell(row + offset[0], col + offset[1]):
					return false # at least one tile will conflict
	# all tiles checked, no conflicts found
	return true

# adds item to inventory -- does not check if it fits
func __add_item(offset:Vector2i, item:Item) -> void:
	var index:int = self.find_item_index(item)
	if check_stacking(index):
		# add to existing index
		self.item_count[index] += 1
	else:
		# new item
		self.items.append(item)
		self.item_pos.append(offset)
		self.add_to_fill(offset, item)
		self.item_count.append(1)

func remove_item(item:Item) -> void:
	var index:int = self.find_item_index(item)
	if index != -1:
		self.remove_item_by_index(index)
		
func remove_item_by_offset(offset:Vector2i) -> void:
	var index:int = -1
	for i in len(self.item_pos):
		if self.item_pos[i] == offset:
			index = i
			break
	if index >= 0:
		self.remove_item_by_index(index)

func remove_item_by_cell(row:int, col:int) -> void:
	var index:int = self.index_at_pos(row, col)
	if index != -1:
		self.remove_item_by_index(index)

func remove_item_by_index(index:int) -> void:
	self.item_count[index] -= 1
	if self.item_count[index] <= 0:
		# clear fill
		self.remove_from_fill(item_pos[index], items[index])
		# clear item data
		self.item_count.pop_at(index)
		self.items.pop_at(index)
		self.item_pos.pop_at(index)

# adds item only if it can be placed
func check_add(offset:Vector2i, item:Item) -> bool:
	if check(offset, item):
		self.__add_item(offset, item)
		return true
	return false
	
func print_inventory() -> void:
	print("::Fill::")
	for i in h:
		var row:String = ""
		for j in w:
			var val:bool = self.get_cell(i, j)
			if val:
				row = row + "1"
			else:
				row = row + "0"
		print(row)
	print("::Items::")
	print(items)
	print(item_count)
	
func _process(delta: float) -> void:
	if debug:
		# default
		print("start config")
		self.print_inventory()
		print("add item")
		var item1:Item = Item.new(4, 4)
		item1.shape_str = "0011010101110100"
		item1.init_shape()
		item1.print_shape()
		self.check_add(Vector2i(0, -1), item1)
		self.check_add(Vector2i(0, 1), item1)
		self.check_add(Vector2i(0, 1), item1)
		self.check_add(Vector2i(0, 1), item1)
		self.print_inventory()
		print("remove item")
		#self.remove_item_by_offset(Vector2i(1, 1))
		self.remove_item_by_cell(2, 1)
		self.remove_item_by_cell(2, 1)
		self.print_inventory()
		debug = false
