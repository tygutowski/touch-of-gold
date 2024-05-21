extends Node2D
var things_pushing_crate = []
var is_on = false

@export var is_down = false
@export var id = 0
@onready var root_tile = Vector2i(get_node("plug").get_global_transform().origin.x, get_node("plug").get_global_transform().origin.y) / 8
@onready var tilemap : TileMap = get_tree().get_first_node_in_group("tilemap")
@onready var midas = get_tree().get_first_node_in_group("midas")

func _ready():
	ElectricityManager.button_list.append(self)
	
func _on_area_2d_body_entered(body):
	if (body.is_in_group("midas") or body.is_in_group("crate")):
		push(body)

func _on_area_2d_body_exited(body):
	if (body.is_in_group("midas") or body.is_in_group("crate")):
		pop(body)

func push(item):
	if things_pushing_crate.is_empty():
		$AnimationPlayer.play("go down")
		is_down = true
		is_on = true
	things_pushing_crate.append(item)

func pop(item):
	things_pushing_crate.erase(item)
	if things_pushing_crate.is_empty():
		$AnimationPlayer.play("go up")
		is_down = false
		is_on = false
