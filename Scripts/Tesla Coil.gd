extends Node2D

@onready var root_tile = Vector2i(get_global_transform().origin.x, get_global_transform().origin.y + 8) / 8 
@onready var tilemap = get_node("../TileMap")
@export var id = 0

func turn_to_gold():
	get_node("golden sprite").visible = true
	get_node("normal sprite").visible = false
	
# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("golden sprite").visible = false
	get_node("normal sprite").visible = true
	tilemap.set_cell(2, root_tile, 0, Vector2i(0, 0))

func _on_area_2d_body_entered(body):
	if body.is_in_group("midas"):
		turn_to_gold()
