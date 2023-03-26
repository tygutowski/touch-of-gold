extends Node2D

@export var id = 0

func _ready():
	get_node("Gate/Sprite2D").texture = load("res://Sprites/gate.png")

func _on_area_2d_body_entered(body):
	if body.is_in_group("midas"):
		get_node("Gate/Sprite2D").texture = load("res://Sprites/golden-gate.png")
