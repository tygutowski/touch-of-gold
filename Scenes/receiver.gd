extends Node2D

func _ready():
	$receiver.visible = true
	$"gold receiver".visible = false


func _on_area_2d_body_entered(body):
	if body.is_in_group("midas"):
		$receiver.visible = false
		$"gold receiver".visible = true
