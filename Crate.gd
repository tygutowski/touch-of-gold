class_name Crate
extends CharacterBody2D

enum crate_materials {WOOD, GOLD, STEEL}
@export var crate_material: crate_materials

var things_above = []
var things_below = []
var things_left = []
var things_right = []

var has_been_pushed = false

@onready var midas = get_tree().get_first_node_in_group("midas")
var midas_direction = 0
# -1 left
# 0 none
# 1 right

@onready var corners = get_node("Corners").get_children()

var is_conductive = false
var is_conducting = false
@onready var tilemap = get_tree().get_first_node_in_group("tilemap")

var held = false

var gravity = 500

func _ready():
	get_node("NumberLabel").text = name.replace("Crate", "")
	$ElectricOverlay.play('default')
	match(crate_material):
		crate_materials.WOOD:
			turn_to_wood()
		crate_materials.GOLD:
			turn_to_gold()
		crate_materials.STEEL:
			turn_to_steel()
	ElectricityManager.crate_list.append(self)

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

func get_connected_crates():
	var checked = {}
	var to_check = [self]
	var connected_crates = []

	while to_check.size() > 0:
		var current = to_check.pop_back()
		if current in checked:
			continue
		checked[current] = true
		connected_crates.append(current)
		
		for direction in [current.things_left, current.things_right]:
			for thing in direction:
				if thing and thing.is_in_group("crate") and thing not in checked:
					to_check.append(thing)

	return connected_crates

func _physics_process(delta):
	# Fall downwards
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Get all connected crates
	var connected_crates = get_connected_crates()

	# Calculate the desired movement for all connected crates
	var overall_velocity = Vector2.ZERO
	for crate in connected_crates:
		overall_velocity += crate.velocity

	# Average velocity across all connected crates
	if connected_crates.size() > 0:
		overall_velocity /= connected_crates.size()

	print(name + " :" + str(connected_crates))
	# Apply the same velocity to all connected crates
	for crate in connected_crates:
		crate.velocity = overall_velocity
		if crate.has_node("VelocityLabel"):
			crate.get_node("VelocityLabel").text = str(crate.velocity.x)
		crate.move_and_slide()

	# Gradually stop all connected crates together
	if overall_velocity != Vector2.ZERO:
		for crate in connected_crates:
			crate.velocity.x = move_toward(crate.velocity.x, 0, 30)

func _on_above_area_2d_body_entered(body):
	if body != self and body not in things_above:
		things_above.append(body)

func _on_above_area_2d_body_exited(body):
	things_above.erase(body)

func _on_left_area_2d_body_entered(body):
	if body != self and body not in things_left:
		things_left.append(body)
	if body.is_in_group("midas"):
		midas_direction = -1

func _on_left_area_2d_body_exited(body):
	things_left.erase(body)
	if body.is_in_group("midas"):
		midas_direction = 0

func _on_right_area_2d_body_entered(body):
	if body != self and body not in things_right:
		things_right.append(body)
	if body.is_in_group("midas"):
		midas_direction = 1

func _on_right_area_2d_body_exited(body):
	things_right.erase(body)
	if body.is_in_group("midas"):
		midas_direction = 0

func _on_below_area_2d_body_entered(body):
	if body != self and body not in things_below:
		things_below.append(body)

func _on_below_area_2d_body_exited(body):
	things_below.erase(body)

func get_all_crates_in_direction(direction: Vector2) -> Array:
	var crates_in_row = [self]
	var current_crate = self
	while true:
		var next_crate = null
		if direction == Vector2.LEFT:
			next_crate = find_next_crate(current_crate.things_left)
		elif direction == Vector2.RIGHT:
			next_crate = find_next_crate(current_crate.things_right)
		if next_crate == null:
			break
		crates_in_row.append(next_crate)
		current_crate = next_crate
	return crates_in_row

func find_next_crate(things: Array) -> Crate:
	for thing in things:
		if thing is Crate:
			return thing
	return null
