extends CharacterBody2D

@onready var tilemap = get_node("../TileMap")
const SPEED = 90.0
const JUMP_VELOCITY = -150.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 500


func _physics_process(delta):
	var player_tile = get_global_transform().origin / 8
	if tilemap.get_cell_atlas_coords(0, player_tile) == Vector2i(-1, -1):
		var tiles_to_change = [Vector2i(player_tile.x+1, player_tile.y), Vector2i(player_tile.x-1, player_tile.y), Vector2i(player_tile.x, player_tile.y+1), Vector2i(player_tile.x, player_tile.y-1)]
		for tile in tiles_to_change:
			if tilemap.get_cell_atlas_coords(0, tile) != Vector2i(-1, -1):
				tilemap.set_cell(0, tile, 0, Vector2i(2,0))
	# Add the gravity.
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

	move_and_slide()
