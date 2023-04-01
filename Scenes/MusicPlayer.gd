extends AudioStreamPlayer

var changing_songs = false

func play_level1(): 
	changing_songs = true
	get_node("Node2D/LEVEL2").playing = false
	if !get_node("Node2D/LEVEL1-1").playing && !get_node("Node2D/LEVEL1").playing:
		get_node("Node2D/LEVEL1").playing = true
	changing_songs = false
	
func play_level2():
	changing_songs = true
	get_node("Node2D/LEVEL1-1").playing = false
	get_node("Node2D/LEVEL1").playing = false
	if !get_node("Node2D/LEVEL2").playing:
		get_node("Node2D/LEVEL2").playing = true
	changing_songs = false

func _on_level_1_intro_finished():
	if !changing_songs:
		get_node("Node2D/LEVEL1-1").playing = true


func _on_level_1_loop_finished():
	if !changing_songs:
		get_node("Node2D/LEVEL1-1").playing = true


func _on_level_2_finished():
	if !changing_songs:
		get_node("Node2D/LEVEL2").playing = true
