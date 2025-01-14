extends Node2D

@export var id = 0
@export var inversed = false
@onready var tilemap = get_node("../TileMap")
@onready var root_tile = get_node("receiver/power tile").get_global_transform().origin / 8
@export_enum("gold", "red", "blue", "green") var color: int
func _ready():
	if color == 0:
		get_node("Gate/Sprite2D").texture = load("res://Sprites/golden-gate.png")
	elif color == 1:
		get_node("Gate/Sprite2D").texture = load("res://Sprites/red-gate.png")
	elif color == 2:
		get_node("Gate/Sprite2D").texture = load("res://Sprites/blue-gate.png")
	if color == 3:
		get_node("Gate/Sprite2D").texture = load("res://Sprites/green-gate.png")

func _on_area_2d_body_entered(body):
	if body.is_in_group("midas"):
		get_node("Gate/Sprite2D").texture = load("res://Sprites/golden-gate.png")

func _process(_delta):
	var any_power = false
	for cell in tilemap.get_surrounding_cells(root_tile):
		if tilemap.get_cell_source_id(2, cell) == 0 && tilemap.get_cell_atlas_coords(2, cell) in Stats.electric_tiles:
			any_power = true
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
		
