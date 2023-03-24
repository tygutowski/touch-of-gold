extends CharacterBody2D

@onready var midas = get_tree().get_first_node_in_group("midas")

var midas_on_left = false
var midas_on_right = false
var gravity = 500
var crate_on_left = null
var crate_on_right = null

var is_gold = false

func turn_to_gold():
	is_gold = true
	get_node("GoldSprite").visible = true
	get_node("WoodSprite").visible = false

func _physics_process(delta):
	velocity.x = 0
	if not is_on_floor():
		velocity.y += gravity * delta
	var direction = Input.get_axis("ui_left", "ui_right")
	if midas_on_left && direction > 0:
		push_box(20)
	elif midas_on_right && direction < 0:
		push_box(-20)
	elif midas_on_left && Input.is_action_pressed("pull"):
		push_box(20)
	elif midas_on_right && Input.is_action_pressed("pull"):
		push_box(-20)
	# if a crate on the left is pushing to the right
	elif crate_on_left && direction > 0:
		push_box(20)
	# if a crate on the right is pushing to the left
	elif crate_on_right && direction < 0:
		push_box(-20)
	move_and_slide()

func _on_left_area_2d_body_entered(body):
	if body == midas:
		midas_on_left = true
		midas.holding_crate = true
	if body.is_in_group("crate") && body != self:
		crate_on_left = true

func _on_right_area_2d_body_entered(body):
	if body == midas:
		midas_on_right = true
		midas.holding_crate = true
	if body.is_in_group("crate") && body != self:
		crate_on_right = true

func _on_left_area_2d_body_exited(body):
	if body == midas:
		midas_on_left = false
		midas.holding_crate = false
	if body.is_in_group("crate") && body != self:
		crate_on_left = false

func _on_right_area_2d_body_exited(body):
	if body == midas:
		midas_on_right = false
		midas.holding_crate = false
	if body.is_in_group("crate") && body != self:
		crate_on_right = false

func push_box(direction):
	velocity.x = direction

func GOLDAREAYUESYES(body):
	if body == midas:
		turn_to_gold()
