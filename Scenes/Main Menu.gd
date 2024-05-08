extends Control

func _process(_delta):
	if Input.is_action_just_pressed("toggle pause") and $"main menu".visible == false:
		$"main menu".visible = true
		$"stage select".visible = false

func _on_exit_to_desktop_pressed():
	get_tree().quit()

func _on_stage_select_pressed():
	$"main menu".visible = false
	$"stage select".visible = true

func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://Scenes/Level1-1.tscn")

func _on_catacombs_pressed():
	get_tree().change_scene_to_file("res://Scenes/Level1-1.tscn")

func _on_garden_pressed():
	get_tree().change_scene_to_file("res://Scenes/Level2-1.tscn")

func _on_library_pressed():
		get_tree().change_scene_to_file("res://Scenes/Level3-1.tscn")

func _on_forge_pressed():
		get_tree().change_scene_to_file("res://Scenes/Level4-1.tscn")

func _on_back_pressed():
	$"main menu".visible = true
	$"stage select".visible = false

func _on_stats_pressed():
	pass

func _on_controls_pressed():
	$"main menu".visible = false
	$"stage select".visible = false
