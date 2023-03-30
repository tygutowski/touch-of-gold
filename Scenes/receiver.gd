extends Node2D
@export var id: int = 0

func _on_area_2d_body_entered(body):
	if body.is_in_group("midas"):
		get_node("Sprite2D").texture = load("res://Sprites/golden-receiver.png")
