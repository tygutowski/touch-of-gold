extends Area2D

@export var stage_id = 1
@export var level_id = 1

func go_to_level():
	get_tree().change_scene_to_file("res://Scenes/Level" + str(stage_id) + "-" + str(level_id) + ".tscn")

func _on_body_entered(body):
	if body.is_in_group("midas"):
		go_to_level()
