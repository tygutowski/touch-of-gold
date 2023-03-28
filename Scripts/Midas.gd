extends CharacterBody2D

@onready var tilemap = get_node("../TileMap")
@onready var midas = get_node("../Midas")
const SPEED = 75.0
const JUMP_VELOCITY = -160.0
var next_to_crate = false
var gravity = 500
var direction = 0
var last_direction_pushed = 0
var crate = null
var pushing_and_moving = false
func _physics_process(delta):
	# the tile the player is currently at. takes the transform and divides by the tile size (8)
	var player_tile = get_node("gold point").get_global_transform().origin / 8

	# list of tiles above, below, left and right of the player
	var tiles_to_change = [Vector2i(player_tile.x+1, player_tile.y), Vector2i(player_tile.x-1, player_tile.y), Vector2i(player_tile.x, player_tile.y+1), Vector2i(player_tile.x, player_tile.y-1), Vector2i(player_tile.x+1, player_tile.y+1), Vector2i(player_tile.x+1, player_tile.y-1), Vector2i(player_tile.x-1, player_tile.y-1), Vector2i(player_tile.x-1, player_tile.y+1)]
	# go through all tiles listed above
	for tile in tiles_to_change:
		if tilemap.get_cell_source_id(0, tile) != 999 && tilemap.get_cell_source_id(0, tile) != 1:
			var tile_to_swap = tilemap.get_cell_atlas_coords(0, tile)
			if tile_to_swap != Vector2i(-1, -1):
				tilemap.set_cell(0, tile, 1, tile_to_swap)
				Stats.blocks_goldified += 1
		if tilemap.get_cell_atlas_coords(1, tile) != Vector2i(-1, -1):
			tilemap.set_cell(1, tile, 1, tilemap.get_cell_atlas_coords(1, tile))
			Stats.blocks_goldified += 1
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

	direction = Input.get_axis("run left", "run right")
	if direction:
		velocity.x = direction * SPEED
		if crate == null || !crate.is_in_group("crate"):
			if velocity.x > 0:
				$RayCast2D.target_position = Vector2(4, 0)
				$Sprite2D.flip_h = false
			if velocity.x < 0:
				$RayCast2D.target_position = Vector2(-4, 0)
				$Sprite2D.flip_h = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if not is_on_floor():
		$AnimationPlayer.play("jumping")
		velocity.y += gravity * delta
	elif Input.is_action_pressed("pull"): # if youre still pressing pull
		if Input.is_action_just_pressed("pull"):
			get_node("RayCast2D").enabled = true
			get_node("RayCast2D").force_raycast_update()
			crate = get_node("RayCast2D").get_collider()
			if crate && crate.is_in_group("crate"):
				crate.being_pulled = true

		last_direction_pushed = midas.get_node("Sprite2D").flip_h
		if crate && crate.is_in_group("crate"):
			velocity.x = 20 * direction
			if direction != 0 && last_direction_pushed == true: #pushing left
				$AnimationPlayer.play("push left")
			elif direction != 0 && last_direction_pushed == false: #pushing right
				$AnimationPlayer.play("push right")
			elif direction == 0 && last_direction_pushed == true: #idle left
				$AnimationPlayer.play("idle push left")
			elif direction == 0 && last_direction_pushed == false: #idle right
				$AnimationPlayer.play("idle push right")
	if !is_on_floor() || crate == null || !crate.is_in_group("crate") || (crate && Input.is_action_just_released("pull")):
		if velocity.x != 0:
			$AnimationPlayer.play("run")
		if velocity.x == 0:
			$AnimationPlayer.play("idle")
	if crate and Input.is_action_just_released("pull"):
		crate.being_pulled = false
		crate = null
	get_node("RayCast2D").enabled = false
	move_and_slide()
