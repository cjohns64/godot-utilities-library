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
var last_conflict_pos:Vector2i = Vector2i.ZERO

enum CHECK_STATUS {Fail_EX, Fail_UN, Fail_CNFL_ST, Fail_CNFL, Pass_ST, Pass}

func _init(_h:int=0, _w:int=0) -> void:
	if _h > 0:
		h = _h
	if _w > 0:
		w = _w
	self.init_fill()

func set_fill(_fill:Array[bool]) -> void:
	fill_tiles = _fill

func add_to_fill(offset:Vector2i, item:Item) -> void:
	self.__add_or_remove_to_fill(item.get_abs_offset(offset), item, true)

func remove_from_fill(offset:Vector2i, item:Item) -> void:
	self.__add_or_remove_to_fill(item.get_abs_offset(offset), item, false)

func __add_or_remove_to_fill(abs_offset:Vector2i, item:Item, add:bool=true) -> void:
	item.trim_to_extent()
	for row in item.h:
		for col in item.w:
			# map item local coords to inventory coords
			if item.get_cell(row, col):
				self.try_set_cell(row + abs_offset[0], col + abs_offset[1], add)

func init_fill() -> void:
	# setup item fill matrix
	#print("init fill")
	for i in (h * w):
		fill_tiles.append(false)

func get_coords(index:int) -> Vector2i:
	@warning_ignore("integer_division")
	return Vector2i(index / w, index % w)

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

func index_at_pos(inv_coords:Vector2i) -> int:
	for i in len(items):
		# check if row and col is active in item i
		var abs_offset:Vector2i = items[i].get_abs_offset(item_pos[i])
		var max_item_row:int = items[i].h - 1 + abs_offset[0]
		var max_item_col:int = items[i].w - 1 + abs_offset[1]
		# check that the item contains the test location
		if (max_item_row < inv_coords[0] or abs_offset[0] > inv_coords[0] 
			or max_item_col < inv_coords[1] or abs_offset[1] > inv_coords[1]):
			continue # test point not in range
		elif items[i].get_cell(inv_coords[0] - abs_offset[0], inv_coords[1] - abs_offset[1]):
			return i # match found
	return -1 # didn't find a match

func find_item_index(item:Item) -> Array[int]:
	var all_matches:Array[int] = []
	for i in len(items):
		if items[i].equals(item):
			all_matches.append(i)
	return all_matches # did not find item

# item_index does not need to be for the item we want to add too,
# any equal items will have the same stacking flags
func __is_stacking_enabled(item_index:int) -> bool:
	# check if the item_index is valid
	if item_index == -1 or item_index > len(self.items):
		return false
	# return if stacking is enabled
	return self.inv_stacking and self.items[item_index].item_stacking

# item_index must correspond to the item we want to add too
func __check_stacking_limit(item_index:int, stack_amount:int) -> bool:
	# return if the new item stack is under the limit
	var limit:int = mini(self.items[item_index].max_item_stack, self.max_inv_stack)
	return self.item_count[item_index] + stack_amount <= limit

func check_stacking(item_index:int, stack_amount:int) -> bool:
	# check if stacking is enabled
	if __is_stacking_enabled(item_index):
		# return if the new item stack is under the limit
		return __check_stacking_limit(item_index, stack_amount)
	return false

# checks if item can be placed at offset, but does not place it
func check(rel_offset:Vector2i, item:Item, stack_amount:int=1) -> CHECK_STATUS:
	item.trim_to_extent()
	var abs_offset:Vector2i = item.get_abs_offset(rel_offset)
	var item_indexes:Array[int] = self.find_item_index(item)
	# find this item
	#var item_index:int = 0
	# check extent is within inventory
	if abs_offset[0] + item.h > h or abs_offset[1] + item.w > w:
		print("check fail::exceeds grid", abs_offset)
		return CHECK_STATUS.Fail_EX # extent passes end of inventory
	if abs_offset[0] < 0 or abs_offset[1] < 0:
		print("check fail::under grid")
		return CHECK_STATUS.Fail_UN # extent under min
	
	# sort cell indexes by their distance from the item origin
	var o = range(0, item.h*item.w)
	var sort_lambda = func(a:int, b:int) -> bool:
		@warning_ignore("integer_division")
		var d1:int = abs((a / item.w) - item.cell_origin[0]) + abs((a % item.w) - item.cell_origin[1])
		@warning_ignore("integer_division")
		var d2:int = abs((b / item.w) - item.cell_origin[0]) + abs((b % item.w) - item.cell_origin[1])
		return d1 < d2
	o.sort_custom(sort_lambda)
	#print("custom order: ", o, " normal: ", range(item.h*item.w))
	
	for i in o:
		var row:int = i / item.w
		var col:int = i % item.w
		if not item.get_cell(row, col):
			continue # only check cells that the item uses
		print("checking cell ", row, " col ", col)
		# check if stacking is allowed
		if item_indexes and __is_stacking_enabled(item_indexes[0]):
			# stacking is allowed
			# only allow overlap with the same item type
			var target_index:int = self.index_at_pos(Vector2i(row + abs_offset[0], col + abs_offset[1]))
			print("target pos: ", Vector2i(row + abs_offset[0], col + abs_offset[1]))
			if target_index == -1:
				# empty tile
				pass # does not affect check result
			elif (target_index in item_indexes and __check_stacking_limit(target_index, stack_amount)):
				# a same item overlap does not need to overlap perfectly
				# new item will be placed at location of existing item
				print("check pass::stacking")
				last_conflict_pos = Vector2i(row + abs_offset[0], col + abs_offset[1])
				return CHECK_STATUS.Pass_ST # overlap and passed conditions
			else:
				print("check fail::conflict w/ stacking")
				last_conflict_pos = Vector2i(row + abs_offset[0], col + abs_offset[1])
				return CHECK_STATUS.Fail_CNFL_ST # at least one tile will conflict
		else:
			# no stacking, just check if the tile is occupied
			if self.get_cell(row + abs_offset[0], col + abs_offset[1]):
				print("check fail::conflict")
				last_conflict_pos = Vector2i(row + abs_offset[0], col + abs_offset[1])
				return CHECK_STATUS.Fail_CNFL # at least one tile will conflict
	# all tiles checked, no conflicts found
	print("check pass::no issues")
	return CHECK_STATUS.Pass

# adds item to inventory -- does not check if it fits
func __add_item(offset:Vector2i, item:Item, is_stacking:bool, stacking_index:int=0, stack_amount:int=1) -> void:
	if is_stacking:
		# add to existing index
		self.item_count[stacking_index] += stack_amount
	else:
		# new item
		self.items.append(item)
		self.item_pos.append(offset)
		self.add_to_fill(offset, item)
		self.item_count.append(stack_amount)

func remove_item(item:Item) -> void:
	var indexes:Array[int] = self.find_item_index(item)
	if len(indexes) > 0:
		self.remove_item_by_index(indexes[0])
		
func remove_item_by_offset(offset:Vector2i) -> void:
	var index:int = -1
	for i in len(self.item_pos):
		if self.item_pos[i] == offset:
			index = i
			break
	if index >= 0:
		self.remove_item_by_index(index)

func remove_item_by_cell(row:int, col:int) -> void:
	var index:int = self.index_at_pos(Vector2i(row, col))
	if index != -1:
		self.remove_item_by_index(index)

func remove_item_by_index(index:int, full_stack:bool=false) -> int:
	print("remove item")
	var amount:int = 1
	if full_stack:
		amount = item_count[index]
	self.item_count[index] -= amount
	if self.item_count[index] <= 0:
		# clear fill
		self.remove_from_fill(item_pos[index], items[index])
		# clear item data
		self.item_count.pop_at(index)
		self.items.pop_at(index)
		self.item_pos.pop_at(index)
	return amount

# adds item only if it can be placed
func check_add(offset:Vector2i, item:Item, stack:int=1) -> bool:
	var result:bool = false
	match check(offset, item, stack):
		CHECK_STATUS.Pass_ST:
			self.__add_item(offset, item, true, self.index_at_pos(last_conflict_pos), stack)
			result = true
		CHECK_STATUS.Pass:
			self.__add_item(offset, item, false, 0, stack)
			result = true
		_: # all fail conditions
			result = false
	return result

func try_move(from:Vector2i, to:Vector2i) -> bool:
	return try_move_and_rotate(from, to, 0)

func try_move_and_rotate(from:Vector2i, to:Vector2i, left_rotations:int, full_stack:bool=false) -> bool:
	# get item at from location
	var index:int = self.index_at_pos(from)
	if index == -1:
		return false # failed to find from item
	# cache item
	var from_item:Item = self.items[index]
	var from_item_offset:Vector2i = self.item_pos[index]
	# remove from inventory
	var removed_amount:int = self.remove_item_by_index(index, full_stack)
	# rotate
	var rotated_item:Item = from_item
	if left_rotations % 4 > 0:
		for r in left_rotations % 4:
			rotated_item = rotated_item.rotate_left()
	elif left_rotations % 4 < 0:
		for r in absi(left_rotations % 4):
			rotated_item = rotated_item.rotate_right()
	# add to new location
	if self.check_add(to, rotated_item, removed_amount):
		return true # item moved successfully
	# move back to starting location with original rotation
	if self.check_add(from_item_offset, from_item, removed_amount):
		return false # failed to move item to destination
	else:
		assert(false) # item disappeared!
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

func sort() -> void:
	print("::Sort Start::")
	print("Items: ", self.items)
	print("Count: ", self.item_count)
	# stack all duplicate items up to limits
	var count:Array[int] = []
	var nodup_items:Array[Item] = []
	
	# sum all like items into one list entry
	for x in len(items):
		var found:bool = false
		for i in len(nodup_items):
			if items[x].equals(nodup_items[i]):
				count[i] += item_count[x]
				found = true
				break
		if not found:
			nodup_items.append(items[x])
			count.append(item_count[x])
	# split item entries that exceed their stacking limit
	var min_items:Array[Item] = []
	var min_count:Array[int] = []
	for i in len(nodup_items):
		var limit:int = mini(nodup_items[i].max_item_stack, self.max_inv_stack)
		@warning_ignore("integer_division")
		var sections = count[i] / limit
		if count[i] % limit != 0:
			sections += 1 # add one pass for remainder
		for j in sections:
			var c:int = limit
			if (j + 1) * limit > count[i]:
				c = count[i] % limit # append remainder
			min_items.append(nodup_items[i])
			min_count.append(c)
	print("||Sort Finished||")
	print("Items: ", min_items)
	print("Count: ", min_count)
	# clear inventory
	self.__clear_inventory()
	
	# maximize upper left, minimize gaps
	# for each item stack at a time,
	# check all placement options, 
	# only add to solution list if it has a lower score then the previous best
	# repeat until all stacks have been placed
	var stack_offset:Array[Vector2i] = []
	for x in len(min_items):
		var min_score:int = 9223372036854775807 # int max value
		var solution_list:Array[Vector2i] = []
		for i in w * h:
			for rotation in 4:
				# rotate item
				var rot_item:Item = __rotate_item(rotation, min_items[x])
				@warning_ignore("integer_division")
				var loc:Vector2i = Vector2i(i/w, i%w)
				# check if item can be placed
				if not __check_stack(loc, rot_item):
					continue # skip to next test
				# place item and score
				var abs_loc:Vector2i = rot_item.get_abs_offset(loc)
				__add_or_remove_to_fill(abs_loc, rot_item, true)
				@warning_ignore("integer_division")
				var score:int = __score_gaps() + i/w + i%w
				# remove item
				__add_or_remove_to_fill(abs_loc, rot_item, false)
				if score < min_score:
					# add to solution
					min_score = score
					solution_list.append(Vector2i(i, rotation))
		assert(len(solution_list) > 0) # failed to find a solution
		# set best result to board, lock in to solution
		var index:int = solution_list[-1][0]
		@warning_ignore("integer_division")
		var sol_loc:Vector2i = Vector2i(index / w, index % w)
		stack_offset.append(sol_loc)
		var sol_item:Item = __rotate_item(solution_list[-1][1], min_items[x])
		min_items[x] = sol_item # update item list with used item
		__add_or_remove_to_fill(sol_item.get_abs_offset(sol_loc), sol_item, true)
	self.items = min_items
	self.item_count = min_count
	self.item_pos = stack_offset
	
func __rotate_item(rotation:int, item:Item) -> Item:
	match rotation:
		1: # left one
			return item.rotate_left()
		2: # right one
			return item.rotate_right()
		3: # left two
			return item.rotate_left().rotate_left()
		_: # no rotation
			return item

func __clear_inventory() -> void:
	for i in w * h:
		fill_tiles[i] = false
	self.items = []
	self.item_count = []
	self.item_pos = []

# paired down version of check, that ignores stacking.
# items in the sort are already at their stacking limit
func __check_stack(rel_offset:Vector2i, item:Item) -> bool:
	var abs_offset:Vector2i = item.get_abs_offset(rel_offset)
	# check extent is within inventory
	if abs_offset[0] + item.h > h or abs_offset[1] + item.w > w:
		return false # extent passes end of inventory
	if abs_offset[0] < 0 or abs_offset[1] < 0:
		return false # extent under min
	# check all the cells
	for i in item.h*item.w:
		@warning_ignore("integer_division")
		var row:int = i / item.w
		var col:int = i % item.w
		if not item.get_cell(row, col):
			continue # only check cells that the item uses
		# check if the tile is occupied
		if self.get_cell(row + abs_offset[0], col + abs_offset[1]):
			return false # at least one tile will conflict
	# all tiles checked, no conflicts found
	return true

func __score_gaps() -> int:
	# O(n) way to score the gaps in the inventory
	# ignores vertical gaps, scores smaller gaps as worse
	var t:int = 0 # total score
	var r:int = 0 # run score increment
	for i in w * h:
		if self.fill_tiles[i]:
			r -= 5 # reset the run increment
		else:
			r += 1
			@warning_ignore("integer_division")
			if i == 0 or i == h - 1 or i / w == 0 or i / w == h - 1:
				r += 2 # extra cost on edges
			t += r
	return t
