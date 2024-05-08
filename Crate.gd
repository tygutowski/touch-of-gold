class_name Crate
extends CharacterBody2D

enum crate_materials {WOOD, GOLD, STEEL}
@export var crate_material: crate_materials


var is_conductive = false
var is_conducting = false
@onready var tilemap = get_node("../TileMap")


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
	ElectricityManager.crate_list.append(self)
	$Sprite2D.frame = 1
	$ElectricOverlay.visible = true
	is_conductive = true
	
func turn_to_steel(): #THIS ADDS MULTIPLE TIMES IF CONVERTING TO GOLD AND BACK
	ElectricityManager.crate_list.append(self)
	$Sprite2D.frame = 2
	$ElectricOverlay.visible = true
	is_conductive = true

	


func _physics_process(delta):
	# decelerate
	velocity.x = move_toward(velocity.x, 0, 5)
	# fall downwards
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	# the direction the crate should move
	var direction = Global.midas.direction
	var collision = get_last_slide_collision()
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("crate"):
			if ((collision.get_normal().x < -0.05) or (collision.get_normal().x > 0.05)) && collision.get_normal().y <= 0:
				collider.velocity.x = Global.midas.direction * 25
	move_and_slide()

func push_box(strength):
	velocity.x = strength
