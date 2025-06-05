extends Node2D

## gate ID to be used with respective receiver
@export var id = 0
## closes the gate when powered.
@export var inversed: bool = false
## color of gate and receiver

@onready var electric_tilemap: TileMapLayer = Global.get_tilemap_manager().get_node("electricity")
@onready var receiver_node = []
@onready var root_tiles = []

func _ready():
	for receiver in get_tree().get_nodes_in_group("receiver"):
		if receiver.id == id:
			receiver_node.append(receiver)
			root_tiles.append(receiver.get_global_transform().origin / 8)

	var color = Global.get_random_pastel_color()
	get_node("ColorIdentifier").modulate = color
	for node in receiver_node:
		node.get_node("ColorIdentifier").modulate = color

func _on_area_2d_body_entered(body):
	if body.is_in_group("midas"):
		get_node("Gate/Sprite2D").texture = load("res://Sprites/golden-gate.png")

func _process(_delta):
	var any_power: bool = false
	# Get all cells around the receiver root tile
	for root_tile in root_tiles:
		for cell in electric_tilemap.get_surrounding_cells(root_tile):
			# If any of the foreground tiles are gold and are conducting electricity
			if electric_tilemap.get_cell_atlas_coords(cell) != Vector2i(-1, -1):
				any_power = true
	
	# If any of the adjacent receiver tiles have power, power the gate
	if inversed:
		if any_power:
			go_down()
		else:
			go_up()
	else:
		if any_power:
			go_up()
		else:
			go_down()
		

func go_down():
	var tween = get_tree().create_tween()
	tween.tween_property(get_node("Gate"), "position", Vector2(4, 8), .25)

func go_up():
	var tween = get_tree().create_tween()
	tween.tween_property(get_node("Gate"), "position", Vector2(4, -8), .25)
	
	
