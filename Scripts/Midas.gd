extends CharacterBody2D

@onready var tilemap : TileMap = get_node("../TileMap")
@onready var midas = get_node("../Midas")

const SPEED = 75.0
const JUMP_VELOCITY = -160.0
const GRAVITY = 500.0

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

func _ready():
	Global.midas = self

func _physics_process(delta):
	var midas_global_position = global_position.floor()
	var midas_tile = tilemap.local_to_map(midas_global_position)
	for offset in nearby_tiles:
		var tile = midas_tile + offset
		for i in [0, 1]:
			var tile_atlas = tilemap.get_cell_atlas_coords(i, tile)
			tilemap.set_cell(i, tile, 1, tile_atlas) # fg
		# for all conductive crates in the world
		var crate = ElectricityManager.find_crate_near(tile)
		if crate != null:
			crate.turn_to_gold()
		
	if Input.is_action_pressed("click"):
		var mouse_pos = get_global_mouse_position()
		var tile_pos = tilemap.local_to_map(mouse_pos)
		if tilemap.get_cell_source_id(0, tile_pos) == -1:
			tilemap.set_cell(0, tile_pos, 1, Vector2i(10, 1))
		else:
			var tile_atlas = tilemap.get_cell_atlas_coords(0, tile_pos)
			tilemap.set_cell(0, tile_pos, 1, tile_atlas)
		ElectricityManager.update_conducting_list()
		ElectricityManager.transmit()
	elif Input.is_action_pressed("rclick"):
		var mouse_pos = get_global_mouse_position()
		var tile_pos = tilemap.local_to_map(mouse_pos)
		tilemap.set_cell(0, tile_pos, -1)
		ElectricityManager.update_conducting_list()
		ElectricityManager.transmit()
	
	direction = Input.get_action_strength("run right") - Input.get_action_strength("run left")
	velocity.x = direction * SPEED
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
