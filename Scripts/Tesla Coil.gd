extends Node2D

@onready var root_tile = get_node("tile").get_global_transform().origin / 8 
@onready var tilemap = get_node("../TileMap")
@export var id = 0

func turn_to_gold():
	get_node("golden sprite").visible = true
	get_node("normal sprite").visible = false
	
# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("golden sprite").visible = false
	get_node("normal sprite").visible = true
	if id > 0:
		tilemap.set_cell(2, root_tile, 0, Vector2i(0, 0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if id > 0:
		var cell_list = tilemap.get_used_cells_by_id(2, 0, Vector2i(0,0)) + tilemap.get_used_cells_by_id(2, 0, Vector2i(1,0)) + tilemap.get_used_cells_by_id(2, 0, Vector2i(3,0))
		for cell in cell_list:
			for nearby in tilemap.get_surrounding_cells(cell):
				# if on gold  AND  nearby is power source
				if tilemap.get_cell_atlas_coords(2, nearby) == Vector2i(0,0):
					pass
				elif tilemap.get_cell_atlas_coords(2, nearby) == Vector2i(1,0):
					pass
				elif tilemap.get_cell_atlas_coords(2, nearby) == Vector2i(3 ,0):
					pass
				elif tilemap.get_cell_source_id(0, nearby) == 1 && tilemap.get_cell_atlas_coords(2, nearby) == Vector2i(2,0):
					tilemap.set_cell(2, nearby, 0, Vector2(3, 0))
				# if on gold and 
				elif tilemap.get_cell_source_id(0, nearby) == 1 && tilemap.get_cell_atlas_coords(2, nearby) != Vector2i(2,0): # strand
					tilemap.set_cell(2, nearby, 0, Vector2i(1,0))
				if tilemap.get_cell_atlas_coords(2, nearby) == Vector2i(0, 1) && tilemap.get_cell_source_id(0, nearby) != 1:
					tilemap.set_cell(2, nearby, -1)
				elif  tilemap.get_cell_atlas_coords(2, nearby) == Vector2i(0, 4) && tilemap.get_cell_source_id(0, nearby) != 1:
					tilemap.set_cell(2, nearby, 0, Vector2(2,0))
func _on_area_2d_body_entered(body):
	if body.is_in_group("midas"):
		turn_to_gold()
