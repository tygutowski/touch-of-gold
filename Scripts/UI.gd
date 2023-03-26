extends Node2D

@onready var pause_menu = get_node("pause menu")
@onready var options_menu = get_node("options menu")

func _process(_delta):
	for node in get_tree().get_nodes_in_group("sfx slider"):
		node.value = Stats.sfx_volume
	for node in get_tree().get_nodes_in_group("music slider"):
		node.value = Stats.music_volume
	if Input.is_action_just_pressed("toggle pause"):
		pause_menu.visible = !pause_menu.visible
		if options_menu.visible:
			options_menu.visible = false
		var level = get_parent()
		level.set_process(!pause_menu.visible)
		level.set_physics_process(!pause_menu.visible)
		level.get_node("Midas").set_process(!pause_menu.visible)
		level.get_node("Midas").set_physics_process(!pause_menu.visible)
func _on_resume_pressed():
	pause_menu.visible = !pause_menu.visible

func _on_restart_pressed():
	get_tree().reload_current_scene()

func _on_options_pressed():
	options_menu.visible = true
	pause_menu.visible = false
func _on_exit_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main Menu.tscn")

func _on_back_pressed():
	options_menu.visible = false
	pause_menu.visible = true

func _on_stats_pressed():
	pass # Replace with function body.

func _on_sfx_slider_value_changed(value):
	set_sfx_to(value)
	Stats.sfx_volume = value
func _on_music_slider_value_changed(value):
	set_music_to(value)
	Stats.music_volume = value
func set_music_to(value):
	for node in get_tree().get_nodes_in_group("music"):
		node.volume_db = linear_to_db(value/8)

func set_sfx_to(value):
	for node in get_tree().get_nodes_in_group("sfx"):
		node.volume_db = linear_to_db(value/8)

func _on_music_slider_ready():
	set_music_to(Stats.music_volume)

func _on_sfx_slider_ready():
	set_sfx_to(Stats.sfx_volume)
