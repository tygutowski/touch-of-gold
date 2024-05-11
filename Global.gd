extends Node

var adjacents = [
	Vector2i( 0,  1),
	Vector2i( 1,  0),
	Vector2i( 0, -1),
	Vector2i(-1,  0)
]

var tilemap = null

var width = 0
var height = 0

var midas = null

func update_tilemap_data():
	tilemap = get_tree().get_first_node_in_group("tilemap")
	if tilemap != null:
		var dimensions = tilemap.get_used_rect().size
		width = dimensions.x
		height = dimensions.y
