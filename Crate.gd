class_name Crate
extends CharacterBody2D

enum crate_materials {WOOD, GOLD, STEEL}
@export var crate_material: crate_materials

var things_above = []
var things_below = []
var things_left = []
var things_right = []

var is_conductive = false
var is_conducting = false
@onready var tilemap = get_tree().get_first_node_in_group("tilemap")

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

func turn_to_wood():
	$Sprite2D.frame = 0
	$ElectricOverlay.visible = false
	is_conductive = false

func turn_to_gold(): #THIS ADDS MULTIPLE TIMES IF CONVERTING TO STEEL AND BACK
	$Sprite2D.frame = 1
	$ElectricOverlay.visible = true
	is_conductive = true
	
func turn_to_steel(): #THIS ADDS MULTIPLE TIMES IF CONVERTING TO GOLD AND BACK
	$Sprite2D.frame = 2
	$ElectricOverlay.visible = true
	is_conductive = true

func _physics_process(delta):
	do_movement(delta)
	check_collisions()

func check_collisions():
	pass

func do_movement(delta):
	# decelerate
	velocity.x = move_toward(velocity.x, 0, 5)
	# fall downwards
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	move_and_slide()

func _on_above_area_2d_body_entered(body):
	if body not in things_above:
		things_above.append(body)


func _on_above_area_2d_body_exited(body):
	things_above.erase(body)


func _on_left_area_2d_body_entered(body):
	if body not in things_left:
		things_left.append(body)


func _on_left_area_2d_body_exited(body):
	things_left.erase(body)


func _on_right_area_2d_body_entered(body):
	if body not in things_right:
		things_right.append(body)


func _on_right_area_2d_body_exited(body):
	things_right.erase(body)


func _on_below_area_2d_body_entered(body):
	if body not in things_below:
		things_below.append(body)

func _on_below_area_2d_body_exited(body):
	things_below.erase(body)
