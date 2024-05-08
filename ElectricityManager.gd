extends Node

var crate_list = []
var battery_list = []

var conducting_list : Array = []
# 0 are non-conductive tiles
# 1 are conductive tiles
# 2 are tiles that are being conducted 

@onready var tilemap : TileMap = get_tree().get_first_node_in_group("tilemap")

func _ready():
	initialize_conducting_list()
	update_conducting_list()
	transmit()

func _process(delta):
	update_conducting_list()
	transmit()

func initialize_conducting_list():
	for x in range(100):
		var row := []
		for y in range(100):
			row.append(0)
		conducting_list.append(row)

	
func update_conducting_list():

	# fill array with non-conductive tiles
	for x in range(100):
		for y in range(100):
			conducting_list[x][y] = 0
	# get all foreground cells
	var tiles = tilemap.get_used_cells(0)
	for tile in tiles:
		var tile_data = tilemap.get_cell_tile_data(0, tile)
		if tile_data.get_custom_data('conductive'):
			conducting_list[tile.x][tile.y] = 1
	
	
	# now get crates too

	# for all conductive crates in the world
	for crate in crate_list:
		# get the center of the crate
		var center = crate.global_position + Vector2(4, 4)
		# if the crate is within the tile stated earlier
		var tile_pos = tilemap.local_to_map(center)
		# if the crate is conductive, and not already conducting
		if crate.is_conductive:
			conducting_list[tile_pos.x][tile_pos.y] = 3

func find_crate_near(map_position):
	for crate in crate_list:
		# get the center of the crate
		var center = crate.global_position + Vector2(4, 4)
		# if the crate is within the tile stated earlier
		var tile_pos = tilemap.local_to_map(center)
		# if the crate is conductive, and not already conducting
		if map_position == tile_pos:
			return crate
	
func clear_electric():
	for x in range(tilemap.get_used_rect().size.x):
		for y in range(tilemap.get_used_rect().size.y):
			tilemap.set_cell(2, Vector2i(x, y), -1)
	for crate in crate_list:
		crate.get_node("ElectricOverlay").visible = false
func transmit():
	
	clear_electric()
	
	# from each battery
	for battery in battery_list:
		# find its tilemap position
		var pos = tilemap.local_to_map(battery.global_position)
		# conduct from that position
		conduct(pos)

func conduct(tile_coordinate):
	# for all directions, up, down, left, right
	for tile_offset in Global.adjacents:
		var new_tile_coordinate = tile_offset + tile_coordinate
		# if the tile is a conductive tile
		var conductivity = conducting_list[new_tile_coordinate.x][new_tile_coordinate.y]
			
		# if it can conduct
		if conductivity == 1:
			# enable electric layer
			tilemap.set_cell(2, new_tile_coordinate, 0, Vector2i(0, 0))
			# enable conductivity
			conducting_list[new_tile_coordinate.x][new_tile_coordinate.y] = 2
			# continue conducting
			conduct(new_tile_coordinate)
			
		# if its a conductive crate
		elif conductivity == 3:
			# enable conductivity
			conducting_list[new_tile_coordinate.x][new_tile_coordinate.y] = 4
			# continue conducting
			var crate = find_crate_near(new_tile_coordinate)
			crate.get_node("ElectricOverlay").visible = true
			conduct(new_tile_coordinate)
