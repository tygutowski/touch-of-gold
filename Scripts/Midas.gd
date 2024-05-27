extends CharacterBody2D

@onready var tilemap : TileMap = get_tree().get_first_node_in_group("tilemap")

const SPEED = 75.0
const JUMP_VELOCITY = -160.0
const GRAVITY = 500.0
var is_pulling = false
@onready var push_raycast : RayCast2D = get_node("RayCast2D")

var direction = 0

var nearby_tiles = [
	Vector2i(0,-1),
	Vector2i(0,0),
	Vector2i(0,1),
	Vector2i(1,-1),
	Vector2i(1,0),
	Vector2i(1,1),
	Vector2i(-1,-1),
	Vector2i(-1,0),
	Vector2i(-1,1)
]

func push_crates():
	push_raycast.force_raycast_update()
	if push_raycast.is_colliding():
		var collider = push_raycast.get_collider()
		if collider and collider.is_in_group("crate"):
			collider.velocity.x = direction * SPEED * 0.9
			collider.move_nearby_crates()
func _physics_process(delta):
	push_crates()
	if Input.is_action_just_pressed("fullscreen"):
		if get_window().get_mode() == Window.MODE_FULLSCREEN:
			get_window().set_mode(Window.MODE_MAXIMIZED)
		else:
			get_window().set_mode(Window.MODE_FULLSCREEN)
	
	var midas_global_position = global_position.floor()
	var midas_tile = tilemap.local_to_map(midas_global_position)
	for offset in nearby_tiles:
		var tile = midas_tile + offset
		for layer in [0]:
			ElectricityManager.turn_tile_to_gold(layer, tile)
		# for all conductive crates in the world
		var crate = ElectricityManager.find_crate_near(tile)
		if crate != null:
			crate.turn_to_gold()
		
	if Input.is_action_pressed("click"):
		var mouse_pos = get_global_mouse_position()
		var tile_pos = tilemap.local_to_map(mouse_pos)
		if tilemap.get_cell_source_id(0, tile_pos) == -1:
			ElectricityManager.turn_tile_to_gold(0, tile_pos)
	elif Input.is_action_pressed("rclick"):
		var mouse_pos = get_global_mouse_position()
		var tile_pos = tilemap.local_to_map(mouse_pos)
		tilemap.set_cell(0, tile_pos, -1)
	
	direction = Input.get_action_strength("run right") - Input.get_action_strength("run left")
	if not is_pulling:
		if direction > 0:
			push_raycast.scale.x = 1
			get_node("Sprite2D").flip_h = false
		elif direction < 0:
			push_raycast.scale.x = -1
			get_node("Sprite2D").flip_h = true
	velocity.x = direction * SPEED
	is_pulling = false
	if Input.is_action_pressed("pull"):
		velocity.x = direction * SPEED * 0.05
		is_pulling = true
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if not is_on_floor():
		$AnimationPlayer.play("jumping")
		velocity.y += GRAVITY * delta

	if is_on_floor():
		if velocity.x != 0:
			$AnimationPlayer.play("run")
		if velocity.x == 0:
			$AnimationPlayer.play("idle")
	
	move_and_slide()
