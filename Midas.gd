extends CharacterBody2D

@onready var tilemap = get_node("../TileMap")
const SPEED = 75.0
const JUMP_VELOCITY = -160.0
var holding_crate = false
var gravity = 500
 
func _physics_process(delta):
	# the tile the player is currently at. takes the transform and divides by the tile size (8)
	var player_tile = get_global_transform().origin / 8

	# list of tiles above, below, left and right of the player
	var tiles_to_change = [Vector2i(player_tile.x+1, player_tile.y), Vector2i(player_tile.x-1, player_tile.y), Vector2i(player_tile.x, player_tile.y+1), Vector2i(player_tile.x, player_tile.y-1)]
	# go through all tiles listed above
	for tile in tiles_to_change:
		var tile_to_swap = tilemap.get_cell_atlas_coords(0, tile)
		if tile_to_swap != Vector2i(-1, -1):
			tilemap.set_cell(0, tile, 1, tile_to_swap)
	
	if tilemap.get_cell_atlas_coords(1, Vector2i(player_tile.x, player_tile.y)) != Vector2i(-1, -1):
		tilemap.set_cell(1, Vector2i(player_tile.x, player_tile.y), 4, tilemap.get_cell_atlas_coords(1, Vector2i(player_tile.x, player_tile.y)))
	
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if velocity.x > 0:
		if holding_crate && Input.is_action_pressed("pull"):
			$AnimationPlayer.play("push right")
		else:
			$AnimationPlayer.play("run right")
	elif velocity.x == 0:
		$AnimationPlayer.play("idle")
	elif velocity.x < 0:
		if holding_crate && Input.is_action_pressed("pull"):
			$AnimationPlayer.play("push left")
		else:
			$AnimationPlayer.play("run left")
	move_and_slide()
