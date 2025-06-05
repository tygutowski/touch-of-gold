class_name Crate
extends CharacterBody2D

enum CrateMaterials { WOOD, GOLD, STEEL }
@export var crate_material: CrateMaterials

# State
var is_conductive = false
var is_conducting = false
var is_being_pushed = false
var has_been_pushed = false
var was_pushed_this_frame = false
var held = false

# Physics constants
const FRICTION = 1200
var gravity = 500

# Neighbors
var things_above = []
var things_below = []
var things_left = []
var things_right = []

# Nodes
@onready var corners = $Corners.get_children()
@onready var tilemap = get_tree().get_first_node_in_group("tilemap")

func _ready():
	Global.get_tilemap_manager().crate_list.append(self)
	$ElectricOverlay.play("default")
	$NumberLabel.text = name.replace("Crate", "")
	
	match crate_material:
		CrateMaterials.WOOD:  turn_to_wood()
		CrateMaterials.GOLD:  turn_to_gold()
		CrateMaterials.STEEL: turn_to_steel()

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	move_and_slide()

func move_manually(amount: float):
	var motion = Vector2(amount, 0)
	var collision = move_and_collide(motion)
	velocity.x = 0 if collision else motion.x / get_physics_process_delta_time()

func move_nearby_crates(push_direction):
	if has_been_pushed:
		return
	has_been_pushed = true
	is_being_pushed = true

	var neighbor_list: Array = []
	match push_direction:
		Global.push_directions.LEFT:  neighbor_list = things_left
		Global.push_directions.RIGHT: neighbor_list = things_right
		_: []

	for crate in neighbor_list:
		if crate.is_in_group("crate"):
			crate.velocity.x = velocity.x
			crate.move_nearby_crates(push_direction)

func push_chain(force: float, direction: int):
	var dir_vec = Vector2(direction, 0)
	var crate_chain = []
	var current = self

	# Step 1: Build crate chain
	while current and current.is_in_group("crate") and current not in crate_chain:
		crate_chain.append(current)
		current = get_next_crate(current, direction)


	# Step 3: Move all crates in reverse order
	for i in range(crate_chain.size() - 1, -1, -1):
		crate_chain[i].move_and_collide(dir_vec * force)


func get_next_crate(crate, direction: int):
	var candidates = crate.things_left if direction == -1 else crate.things_right
	for neighbor in candidates:
		if neighbor.is_in_group("crate") and abs(crate.global_position.x - neighbor.global_position.x) <= 2.0:
			return neighbor
	return null


# Material behaviors
func turn_to_wood():
	$Sprite2D.frame = 0
	$ElectricOverlay.visible = false
	is_conductive = false

func turn_to_gold():
	$Sprite2D.frame = 1
	$ElectricOverlay.visible = true
	is_conductive = true

func turn_to_steel():
	$Sprite2D.frame = 2
	$ElectricOverlay.visible = true
	is_conductive = true

# Collision detection helpers
func _on_above_area_2d_body_entered(body): _add_unique(body, things_above)
func _on_above_area_2d_body_exited(body):  things_above.erase(body)

func _on_below_area_2d_body_entered(body): _add_unique(body, things_below)
func _on_below_area_2d_body_exited(body):  things_below.erase(body)

func _on_left_area_2d_body_entered(body): _add_unique(body, things_left)
func _on_left_area_2d_body_exited(body):  things_left.erase(body)

func _on_right_area_2d_body_entered(body): _add_unique(body, things_right)
func _on_right_area_2d_body_exited(body):  things_right.erase(body)

func _add_unique(body, list):
	if body != self and body not in list:
		list.append(body)
