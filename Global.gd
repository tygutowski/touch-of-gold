extends Node

var adjacents = [
	Vector2i( 0,  1),
	Vector2i( 1,  0),
	Vector2i( 0, -1),
	Vector2i(-1,  0)
]

enum push_directions {
	NONE =  0,
	LEFT = -1,
	RIGHT = 1
}

var width = 15
var height = 15

func set_map_size(dimensions):
	width = dimensions.x
	height = dimensions.y

var midas = null

func get_random_pastel_color() -> Color:
	var hue = randf() # Random hue (0 to 1)
	var saturation = randf_range(0.2, 0.5) # Low saturation for pastel
	var value = randf_range(0.85, 1.0) # High brightness for pastel
	return Color.from_hsv(hue, saturation, value)


func get_tilemap_manager():
	return get_tree().get_first_node_in_group("Level").get_node("Tilemap")
