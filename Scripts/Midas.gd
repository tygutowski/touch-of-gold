extends CharacterBody2D

@onready var tilemap = get_node("../TileMap")
@onready var midas = get_node("../Midas")

const SPEED = 75.0
const JUMP_VELOCITY = -160.0
const GRAVITY = 500.0

var next_to_crate = false
var direction = 0
var last_direction_pushed = 0
var crate = null
var pushpulling_crate = false
var pushpulling_speed = 25
var time = 0

func _ready():
	Global.midas = self

func _physics_process(delta):
	if Input.is_action_pressed("click"):
		var mouse_pos = get_global_mouse_position()
		var tile_pos = tilemap.local_to_map(mouse_pos)
		tilemap.set_cell(0, tile_pos, 1, Vector2i(2, 0))
		ElectricityManager.update_conducting_list()
		ElectricityManager.transmit()
	elif Input.is_action_pressed("rclick"):
		var mouse_pos = get_global_mouse_position()
		var tile_pos = tilemap.local_to_map(mouse_pos)
		tilemap.set_cell(0, tile_pos, -1)
		ElectricityManager.update_conducting_list()
		ElectricityManager.transmit()
	time += delta
	if time > 0.25:
		time = 0
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# in air
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
		velocity.y += GRAVITY * delta
		
	$RayCast2D.enabled = true
	$RayCast2D.force_raycast_update()
	if is_on_wall() and $RayCast2D.is_colliding:
		var collider = $RayCast2D.get_collider()
	
	# PULLING A CRATE
	
	
	if is_on_floor() and Input.is_action_pressed("pull"):
		if Input.is_action_just_pressed("pull"):
			get_node("RayCast2D").enabled = true
			get_node("RayCast2D").force_raycast_update()
			crate = get_node("RayCast2D").get_collider()
			if crate && crate.is_in_group("crate"):
				crate.held = true

		last_direction_pushed = midas.get_node("Sprite2D").flip_h
		if crate && crate.is_in_group("crate"):
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

	# RELEASE A CRATE~
	if crate and Input.is_action_just_released("pull"):
		crate.held = false
		crate = null
	get_node("RayCast2D").enabled = false

	move_and_slide()

func push_box(crate, strength):
	if direction:
		if !get_node("metal").playing:
			get_node("metal").playing = true
		crate.velocity.x = strength * direction
		velocity.x = (strength - 5) * direction
	return (direction != 0)
