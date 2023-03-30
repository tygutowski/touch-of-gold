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
var pushpulling_crate = false
var pushpulling_speed = 25
var time = 0
func recalculate_electricity():
	# remove all linking electric tiles
	var linkers = tilemap.get_used_cells_by_id(2, 0, Vector2i(0,1)) + tilemap.get_used_cells_by_id(2, 0, Vector2i(0,2)) + tilemap.get_used_cells_by_id(2, 0, Vector2i(0,3)) + tilemap.get_used_cells_by_id(2, 0, Vector2i(0,4)) + tilemap.get_used_cells_by_id(2, 0, Vector2i(0,5))
	for cra in get_tree().get_nodes_in_group("crate"):
		if cra.get_node("AnimationPlayer").get_current_animation() == "electric":
			cra.get_node("AnimationPlayer").play("gold")
	for cell in linkers:
		tilemap.erase_cell(2, cell)
	recursively_calc()
func recursively_calc():
	var any_more = false
	# get all power cells
	var cell_list = tilemap.get_used_cells_by_id(2, 0, Vector2i(0,0)) + tilemap.get_used_cells_by_id(2, 0, Vector2i(0,1)) + tilemap.get_used_cells_by_id(2, 0, Vector2i(0,2)) + tilemap.get_used_cells_by_id(2, 0, Vector2i(0,3)) + tilemap.get_used_cells_by_id(2, 0, Vector2i(0,4)) + tilemap.get_used_cells_by_id(2, 0, Vector2i(0,5))
	# go through all crates
	# for each power cell
	for cell in cell_list:
		# turn each nerby cell into power cells
		for nearby in tilemap.get_surrounding_cells(cell):
			if tilemap.get_cell_source_id(0, nearby) == 1 && tilemap.get_cell_atlas_coords(2, nearby) == Vector2i(0,0):
				pass
			elif tilemap.get_cell_source_id(0, nearby) == 1 && tilemap.get_cell_atlas_coords(2, nearby) == Vector2i(0,1): # strand
				pass
			elif tilemap.get_cell_source_id(0, nearby) == 1 && tilemap.get_cell_atlas_coords(2, nearby) == Vector2i(-1, -1): # strand
				var data = tilemap.get_cell_tile_data(0, nearby)
				if data:
					if data.get_custom_data("conductive"):
						if tilemap.get_cell_atlas_coords(0, nearby) == Vector2i(14, 0) || tilemap.get_cell_atlas_coords(0, nearby) == Vector2i(18, 18):
							tilemap.set_cell(2, nearby, 0, Vector2i(0, 5))
						elif tilemap.get_cell_atlas_coords(0, nearby) == Vector2i(15, 0) || tilemap.get_cell_atlas_coords(0, nearby) == Vector2i(19, 18):
							tilemap.set_cell(2, nearby, 0, Vector2i(0, 4))
						elif tilemap.get_cell_atlas_coords(0, nearby) == Vector2i(14, 1) || tilemap.get_cell_atlas_coords(0, nearby) == Vector2i(18, 19):
							tilemap.set_cell(2, nearby, 0, Vector2i(0, 2))
						elif tilemap.get_cell_atlas_coords(0, nearby) == Vector2i(15, 1) || tilemap.get_cell_atlas_coords(0, nearby) == Vector2i(19, 19):
							tilemap.set_cell(2, nearby, 0, Vector2i(0, 3))
						else:
							tilemap.set_cell(2, nearby, 0, Vector2i(0,1))
						any_more = true
	# if there are no more tiles to be turned to electric
	if !any_more:
		# check for all gold crates
		var crates = get_tree().get_nodes_in_group("crate")
		for cra in crates:
			if cra.get_node("AnimationPlayer").get_current_animation() == "gold":
				var gp = cra.point.get_global_transform().origin
				var tiles_to_check = [
				Vector2i(gp.x+4, gp.y+5)/8, # 1
				Vector2i(gp.x+5, gp.y+4)/8, # 2
				Vector2i(gp.x+5, gp.y  )/8, # 3
				Vector2i(gp.x+5, gp.y-4)/8, # 4
				Vector2i(gp.x+4, gp.y-5)/8, # 5
				Vector2i(gp.x  , gp.y-5)/8, # 6
				Vector2i(gp.x-4, gp.y-5)/8, # 7
				Vector2i(gp.x-5, gp.y-4)/8, # 8
				Vector2i(gp.x-5, gp.y  )/8, # 9
				Vector2i(gp.x-5, gp.y+4)/8, # 10
				Vector2i(gp.x-4, gp.y+5)/8, # 11
				Vector2i(gp.x  , gp.y+5)/8  # 12
				]
				var already_electrified = false
				# see if any nearby tiles are electric
				for tile in tiles_to_check:
					if tilemap.get_cell_source_id(2, tile) == 0:
						if cra.get_node("AnimationPlayer").get_current_animation() == "gold":
							cra.get_node("AnimationPlayer").play("electric")
							#print("T")
							already_electrified = true
							break
				# see if any nearby crates are electric
				if !already_electrified:
					for ray in get_tree().get_nodes_in_group("raycast"):
						ray.enabled = true
						ray.force_raycast_update()
						var col = ray.get_collider()
						if col:
							if col.is_in_group("crate"):
								if col.get_node("AnimationPlayer").get_current_animation() == "electric":
									if cra.get_node("AnimationPlayer").get_current_animation() == "gold":
										cra.get_node("AnimationPlayer").play("electric")
										#print("C")
										break
	for cra in get_tree().get_nodes_in_group("crate"):
		# if any are electric
		if cra.get_node("AnimationPlayer").get_current_animation() == "electric":
			var tile = cra.get_global_transform().origin / 8
			# turn nearby cells into electric tiles
			for nearby in tilemap.get_surrounding_cells(tile):
				if tilemap.get_cell_source_id(0, nearby) == 1 && tilemap.get_cell_atlas_coords(2, nearby) == Vector2i(-1, -1): # strand
					var data = tilemap.get_cell_tile_data(0, nearby)
					if data:
						if data.get_custom_data("conductive"):
							if tilemap.get_cell_atlas_coords(0, nearby) == Vector2i(14, 0) || tilemap.get_cell_atlas_coords(0, nearby) == Vector2i(18, 18):
								tilemap.set_cell(2, nearby, 0, Vector2i(0, 5))
							elif tilemap.get_cell_atlas_coords(0, nearby) == Vector2i(15, 0) || tilemap.get_cell_atlas_coords(0, nearby) == Vector2i(19, 18):
								tilemap.set_cell(2, nearby, 0, Vector2i(0, 4))
							elif tilemap.get_cell_atlas_coords(0, nearby) == Vector2i(14, 1) || tilemap.get_cell_atlas_coords(0, nearby) == Vector2i(18, 19):
								tilemap.set_cell(2, nearby, 0, Vector2i(0, 2))
							elif tilemap.get_cell_atlas_coords(0, nearby) == Vector2i(15, 1) || tilemap.get_cell_atlas_coords(0, nearby) == Vector2i(19, 19):
								tilemap.set_cell(2, nearby, 0, Vector2i(0, 3))
							else:
								tilemap.set_cell(2, nearby, 0, Vector2i(0,1))
							any_more = true
	
	if any_more:
		recursively_calc()
func _physics_process(delta):
	time += delta
	if time > 0.25:
		time = 0
		recalculate_electricity()
	# the tile the player is currently at. takes the transform and divides by the tile size (8)
	var gp = get_node("gold point").get_global_transform().origin
	
	# list of tiles above, below, left and right of the player
	var tiles_to_change = [Vector2i(gp.x+4, gp.y+6)/8, Vector2i(gp.x+4, gp.y-4)/8, Vector2i(gp.x+4, gp.y)/8, Vector2i(gp.x-4, gp.y-4)/8, Vector2i(gp.x-4, gp.y+6)/8, Vector2i(gp.x-4, gp.y)/8, Vector2i(gp.x, gp.y)/8, Vector2i(gp.x, gp.y)/8]
	# go through all tiles listed above
	for tile in tiles_to_change:
		if tilemap.get_cell_source_id(0, tile) != 999 && tilemap.get_cell_source_id(0, tile) != 1:
			var tile_to_swap = tilemap.get_cell_atlas_coords(0, tile)
			if tile_to_swap != Vector2i(-1, -1):
				tilemap.set_cell(0, tile, 1, tile_to_swap)
				Stats.blocks_goldified += 1
				recalculate_electricity()
		if tilemap.get_cell_atlas_coords(1, tile) != Vector2i(-1, -1):
			tilemap.set_cell(1, tile, 1, tilemap.get_cell_atlas_coords(1, tile))
			Stats.blocks_goldified += 1
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# in air
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
