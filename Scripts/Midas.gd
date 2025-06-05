extends CharacterBody2D

@onready var foreground_map: TileMapLayer = get_tree().get_first_node_in_group("Level").get_node("Tilemap/foreground")
@onready var push_raycast: RayCast2D = $RayCast2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer

const SPEED = 80.0
const JUMP_VELOCITY = -160.0
const GRAVITY = 500.0
const CRATE_PUSH_FORCE = 300.0

var direction := 0
var facing_direction := 1
var is_pulling := false
var all_crates := []

var nearby_tiles := [
	Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1),
	Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1),
	Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1)
]

func _ready():
	all_crates = get_tree().get_nodes_in_group("crate")

func _physics_process(delta):
	handle_push()
	handle_movement(delta)
	handle_input()
	handle_tile_interaction()
	handle_animation()

	move_and_slide()

func handle_push():
	push_raycast.force_raycast_update()
	if push_raycast.is_colliding():
		var collider = push_raycast.get_collider()
		if collider and collider.is_in_group("crate") and collider is RigidBody2D:
			var impulse = Vector2(direction, 0) * CRATE_PUSH_FORCE
			collider.apply_central_impulse(impulse)

func get_current_direction() -> Global.push_directions:
	if is_zero_approx(direction):
		return Global.push_directions.NONE
	elif direction > 0:
		return Global.push_directions.RIGHT
	elif direction < 0:
		return Global.push_directions.LEFT
	return Global.push_directions.NONE

func handle_input():
	if Input.is_action_just_pressed("fullscreen"):
		var mode = get_window().get_mode()
		get_window().set_mode(Window.MODE_MAXIMIZED if mode == Window.MODE_FULLSCREEN else Window.MODE_FULLSCREEN)

	direction = Input.get_action_strength("run right") - Input.get_action_strength("run left")

	if not is_pulling:
		if direction > 0:
			push_raycast.scale.x = 1
			facing_direction = 1
			get_node("Sprite2D").flip_h = false
		elif direction < 0:
			facing_direction = -1
			push_raycast.scale.x = -1
			get_node("Sprite2D").flip_h = true

	is_pulling = Input.is_action_pressed("pull")
	velocity.x = direction * SPEED * (0.1 if is_pulling else 1.0)
	
	if Input.is_action_just_pressed("kick"):
		var hit = $RayCast2D.get_collider()
		if hit and hit.is_in_group("crate"):
			hit.kick(facing_direction) # or -1 for left

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func handle_movement(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0

func handle_animation():
	if not is_on_floor():
		anim.play("jumping")
	elif abs(velocity.x) > 0:
		anim.play("run")
	else:
		anim.play("idle")

func handle_tile_interaction():
	var center_tile = foreground_map.local_to_map(global_position.floor())
	for offset in nearby_tiles:
		var tile = center_tile + offset
		Global.get_tilemap_manager().turn_tile_to_gold(tile)
		var crate = Global.get_tilemap_manager().find_crate_near(tile)
		if crate: crate.turn_to_gold()

	var mouse_tile = foreground_map.local_to_map(get_global_mouse_position())
	if Input.is_action_pressed("click"):
		if foreground_map.get_cell_source_id(mouse_tile) == -1:
			Global.get_tilemap_manager().turn_tile_to_gold(mouse_tile)
	elif Input.is_action_pressed("rclick"):
		foreground_map.set_cell(mouse_tile, -1)
