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
const FRICTION = 1200
var held = false

var gravity = 500

func _ready():
	$ElectricOverlay.play('default')
	match(crate_material):
		crate_materials.WOOD:
			turn_to_wood()
		crate_materials.GOLD:
			turn_to_gold()
		crate_materials.STEEL:
			turn_to_steel()
	ElectricityManager.crate_list.append(self)

func move_nearby_crates():
	# dont check this crate again
	has_been_pushed = true
	# for all nearby crates
	for direction in [things_left, things_right]:
		for thing in direction:
			if thing.is_in_group("crate"):
				if not thing.has_been_pushed:
					thing.velocity.x = velocity.x
					thing.move_nearby_crates()
					thing.get_node("VelocityLabel").text = str(velocity.x)
					thing.move_and_slide()

func _physics_process(delta):
	has_been_pushed = false
	if is_on_floor():
		velocity.y = 0
	else:
		velocity.y += gravity * delta
	get_node("VelocityLabel").text = str(velocity.x)
	move_and_slide()
	
	velocity.x = move_toward(velocity.x, 0, 1000)
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
