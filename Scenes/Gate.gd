extends Node2D

## gate ID to be used with respective receiver
@export var id = 0
## closes the gate when powered.
@export var inversed: bool = false
## color of gate and receiver
@export_enum("gold", "red", "blue", "green") var color: int

@onready var tilemap: TileMap = get_node("../TileMap")
@onready var receiver_node = []
@onready var root_tiles = []

func _ready():
	for receiver in get_tree().get_nodes_in_group("receiver"):
		if receiver.id == id:
			receiver_node.append(receiver)
			root_tiles.append(receiver.get_global_transform().origin / 8)

	if color == 0:
		get_node("Gate/Sprite2D").texture = load("res://Sprites/golden-gate.png")
		for node in receiver_node:
			node.get_node("Sprite2D").texture = load("res://Sprites/golden-receiver.png")
	elif color == 1:
		get_node("Gate/Sprite2D").texture = load("res://Sprites/red-gate.png")
		for node in receiver_node:
			node.get_node("Sprite2D").texture = load("res://Sprites/red-receiver.png")
	elif color == 2:
		get_node("Gate/Sprite2D").texture = load("res://Sprites/blue-gate.png")
		for node in receiver_node:
			node.get_node("Sprite2D").texture = load("res://Sprites/blue-receiver.png")
	if color == 3:
		get_node("Gate/Sprite2D").texture = load("res://Sprites/green-gate.png")
		for node in receiver_node:
			node.get_node("Sprite2D").texture = load("res://Sprites/green-receiver.png")

func _on_area_2d_body_entered(body):
	if body.is_in_group("midas"):
		get_node("Gate/Sprite2D").texture = load("res://Sprites/golden-gate.png")

func _process(_delta):
	var any_power: bool = false
	# Get all cells around the receiver root tile
	for root_tile in root_tiles:
		for cell in tilemap.get_surrounding_cells(root_tile):
			# If any of the foreground tiles are gold and are conducting electricity
			if tilemap.get_cell_source_id(2, cell) == 0 && tilemap.get_cell_atlas_coords(2, cell) in Stats.electric_tiles:
				any_power = true
	
	# If any of the adjacent receiver tiles have power, power the gate
	if any_power:
		if inversed:
			$AnimationPlayer.play("go down")
		else:
			$AnimationPlayer.play("go up")
	else:
		if inversed:
			$AnimationPlayer.play("go up")
		else:
			$AnimationPlayer.play("go down")
		
