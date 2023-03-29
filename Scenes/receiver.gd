extends Node2D

@export_enum("gold", "red", "blue", "green") var color: int
func _ready():
	if color == 0:
		get_node("Sprite2D").texture = load("res://Sprites/golden-receiver.png")
	elif color == 1:
		get_node("Sprite2D").texture = load("res://Sprites/red-receiver.png")
	elif color == 2:
		get_node("Sprite2D").texture = load("res://Sprites/blue-receiver.png")
	if color == 3:
		get_node("Sprite2D").texture = load("res://Sprites/green-receiver.png")

func _on_area_2d_body_entered(body):
	if body.is_in_group("midas"):
		get_node("Sprite2D").texture = load("res://Sprites/golden-receiver.png")
