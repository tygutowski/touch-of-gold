extends Node2D
var things_pushing_crate = []
@export var is_down = false
@export var id = 0
func _ready():
	$"Button-pusher".texture = load("res://Sprites/button-pusher.png")
	
func _on_area_2d_body_entered(body):
	if (body.is_in_group("midas") or body.is_in_group("crate")) && !is_down:
		pop(body)

func _on_area_2d_body_exited(body):
	if (body.is_in_group("midas") or body.is_in_group("crate")) && is_down:
		push(body)

func _on_area_2d_2_body_entered(body):
	if body.is_in_group("midas"):
		$"Button-pusher".texture = load("res://Sprites/button-pusher-gold.png")

func pop(item):
	if things_pushing_crate.is_empty():
		$AnimationPlayer.play("go down")
	things_pushing_crate.append(item)
func push(item):
	things_pushing_crate.erase(item)
	if things_pushing_crate.is_empty():
		$AnimationPlayer.play("go up")

func open_gate():
	for gate in get_tree().get_nodes_in_group("gate"):
		if gate.id == id:
			gate.get_node("AnimationPlayer").play("go up")

func close_gate():
	for gate in get_tree().get_nodes_in_group("gate"):
		if gate.id == id:
			gate.get_node("AnimationPlayer").play("go down")
