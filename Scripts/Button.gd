extends Node2D
var things_pushing_crate = []
@export var is_down = false
@export var id = 0
@onready var root_tile = Vector2i(get_node("plug").get_global_transform().origin.x, get_node("plug").get_global_transform().origin.y) / 8
@onready var tilemap = get_node("../TileMap")
@onready var midas = get_tree().get_first_node_in_group("midas")
func _ready():
	$"Button-pusher".texture = load("res://Sprites/button-pusher.png")
	tilemap.set_cell(2, root_tile, -1)

func _on_area_2d_body_entered(body):
	if (body.is_in_group("midas") or body.is_in_group("crate")):
		push(body)

func _on_area_2d_body_exited(body):
	if (body.is_in_group("midas") or body.is_in_group("crate")):
		pop(body)

func _on_area_2d_2_body_entered(body):
	if body.is_in_group("midas"):
		$"Button-pusher".texture = load("res://Sprites/button-pusher-gold.png")

func push(item):
	if things_pushing_crate.is_empty():
		$AnimationPlayer.play("go down")
	things_pushing_crate.append(item)

func pop(item):
	things_pushing_crate.erase(item)
	if things_pushing_crate.is_empty():
		$AnimationPlayer.play("go up")

func power_on():
	tilemap.set_cell(2, root_tile, 0, Vector2(0,0))
	midas.recalculate_electricity()

func power_off():
	tilemap.set_cell(2, root_tile, -1)
	midas.recalculate_electricity()
