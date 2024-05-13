extends Node

var crate_list = []
var battery_list = []
var button_list = []

var conducting_list : Array = []
# -3 are empty tiles with horizontal particles
# -2 are empty tiles with vertical particles
# -1 are empty tiles
#  0 are non-conductive tiles
#  1 are conductive tiles
#  2 are conducting tiles 
#  3 are conductive crates
#  4 are conducting crates

var actively_conducting_list : Array = []

@onready var tilemap : TileMap = get_tree().get_first_node_in_group("tilemap")

func _ready():
	# get tilemap width and height
	Global.update_tilemap_data()
	# get all of the tiles
	initialize_conducting_list()

func _process(_delta):
	# clear the electric tiles
	clear_electric_tiles()
	# redraw the electric tiles
	fill_electric_tiles()
	
	#update_conducting_list()
	#update_particles()
	pass

func turn_tile_to_gold(layer, coordinate):
	var atlas = tilemap.get_cell_atlas_coords(layer, coordinate)
	if tilemap.get_cell_source_id(0, coordinate) != -1: # if its not an empty tile
		tilemap.set_cell(layer, coordinate, 1, atlas)
		conducting_list[coordinate.x][coordinate.y] = 1

func initialize_conducting_list():
	# fills the conductive tilemap with empty data
	for x in range(Global.width):
		var row := []
		for y in range(Global.height):
			row.append(-1)
		conducting_list.append(row)
		
	# get all foreground cells
	var tiles = tilemap.get_used_cells(0)
	for tile in tiles:
		var tile_data = tilemap.get_cell_tile_data(0, tile)
		if tile_data.get_custom_data('conductive'):
			conducting_list[tile.x][tile.y] = 1
		else:
			conducting_list[tile.x][tile.y] = 0

func update_conducting_crates():
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
	
func clear_electric_tiles():
	for tile in actively_conducting_list:
		conducting_list[tile.x][tile.y] = 1
		tilemap.set_cell(2, Vector2i(tile.x, tile.y), -1)
	actively_conducting_list.clear()
	for crate in crate_list:
		crate.get_node("ElectricOverlay").visible = false

func fill_electric_tiles():
	# from each battery
	for battery in battery_list:
		# find its tilemap position
		var battery_coordinate = tilemap.local_to_map(battery.global_position)
		# conduct from that position
		conduct_in_all_dirs(battery_coordinate)
	for button in button_list:
		if button.is_on:
			var button_coordinate = tilemap.local_to_map(button.global_position)
			# conduct from the tile below
			conduct_in_dir(Vector2i(0, 1), button_coordinate)

func conduct_in_dir(tile_coordinate, offset : Vector2i):
	conduct(tile_coordinate + offset)
	
func conduct_in_all_dirs(tile_coordinate):
	for tile_offset in Global.adjacents:
		conduct_in_dir(tile_coordinate, tile_offset)

func electrify_tile(tile_coordinate):
	var tile_atlas = tilemap.get_cell_atlas_coords(0, tile_coordinate)
	# enable electric layer
	tilemap.set_cell(2, tile_coordinate, 2, tile_atlas)
	# enable conductivity
	actively_conducting_list.append(tile_coordinate)
	conducting_list[tile_coordinate.x][tile_coordinate.y] = 2
	# continue conducting

func conduct(tile_coordinate):
	# if the tile is a conductive tile
	var conductivity = conducting_list[tile_coordinate.x][tile_coordinate.y]
	# if it can conduct
	if conductivity == 1:
		electrify_tile(tile_coordinate)

		conduct_in_all_dirs(tile_coordinate)
		
	# if its a conductive crate
	elif conductivity == 3:
		# enable conductivity
		conducting_list[tile_coordinate.x][tile_coordinate.y] = 4
		# continue conducting
		var crate = find_crate_near(tile_coordinate)
		crate.get_node("ElectricOverlay").visible = true
		conduct_in_all_dirs(tile_coordinate)
