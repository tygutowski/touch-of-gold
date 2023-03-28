extends Node2D

@export var id = 0
@onready var tilemap = get_node("../TileMap")
@onready var root_tile = get_node("plug").get_global_transform().origin / 8

func _ready():
	get_node("Gate/Sprite2D").texture = load("res://Sprites/gate.png")
	tilemap.set_cell(2, root_tile, 0, Vector2i(2,0))

func _on_area_2d_body_entered(body):
	if body.is_in_group("midas"):
		get_node("Gate/Sprite2D").texture = load("res://Sprites/golden-gate.png")

func _process(_delta):
	var any_power = false
	for cell in tilemap.get_surrounding_cells(root_tile):
		if tilemap.get_cell_source_id(2, cell) == 0 && tilemap.get_cell_atlas_coords(2, cell) == Vector2i(1,0):
			any_power = true
	if any_power:
		$AnimationPlayer.play("go up")
	else:
		$AnimationPlayer.play("go down")
