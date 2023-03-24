extends Node2D

@export var is_down = false

func _ready():
	$AnimationPlayer.play("go up")
	$"Button-pusher".texture = load("res://button-pusher.png")
	
func _on_area_2d_body_entered(body):
	if (body.is_in_group("midas") or body.is_in_group("crate")) && !is_down:
		$AnimationPlayer.play("go down")


func _on_area_2d_body_exited(body):
	if (body.is_in_group("midas") or body.is_in_group("crate")) && is_down:
		$AnimationPlayer.play("go up")


func _on_area_2d_2_body_entered(body):
	# TURN T OGODL!!!
	if body.is_in_group("midas"):
		$"Button-pusher".texture = load("res://button-pusher-gold.png")
