extends CharacterBody2D

@onready var midas = get_tree().get_first_node_in_group("midas")

var midas_on_left = false
var midas_on_right = false
var gravity = 500
var crate_on_left = null
var crate_on_right = null
var being_pulled = false
var is_gold = false

func turn_to_gold():
	is_gold = true
	get_node("GoldSprite").visible = true
	get_node("WoodSprite").visible = false

func _physics_process(delta):
	velocity.x = 0
	if not is_on_floor():
		velocity.y += gravity * delta
	var direction = midas.direction
	if midas_on_left && direction > 0:
		push_box(20)
	elif midas_on_right && direction < 0:
		push_box(20)
	elif midas_on_left and being_pulled:
		push_box(320)
	elif midas_on_right and being_pulled:
		push_box(320)
	# if a crate on the left is pushing to the right
	if crate_on_left && direction > 0:
		push_box(20)
	# if a crate on the right is pushing to the left
	if crate_on_right && direction < 0:
		push_box(20)
	if get_real_velocity().x != 0 && !get_node("gold push audio").playing:
		get_node("gold push audio").playing = true
	elif is_zero_approx(get_real_velocity().x) && get_node("gold push audio").playing:
		get_node("gold push audio").playing = false
	move_and_slide()

func _on_left_area_2d_body_entered(body):
	if body == midas:
		midas_on_left = true
		if midas.crate == self:
			midas.next_to_crate = true
	if body.is_in_group("crate") && body != self:
		crate_on_left = true

func _on_right_area_2d_body_entered(body):
	if body == midas:
		midas_on_right = true
		if midas.crate == self:
			midas.next_to_crate = true
	if body.is_in_group("crate") && body != self:
		crate_on_right = true

func _on_left_area_2d_body_exited(body):
	if body == midas:
		midas_on_left = false
		if midas.crate == self:
			midas.next_to_crate = false
			being_pulled = false
			midas.crate = null
	if body.is_in_group("crate") && body != self:
		crate_on_left = false

func _on_right_area_2d_body_exited(body):
	if body == midas:
		midas_on_right = false
		if midas.crate == self:
			midas.next_to_crate = false
			being_pulled = false
			midas.crate = null
	if body.is_in_group("crate") && body != self:
		crate_on_right = false

func push_box(strength):
	velocity.x = midas.direction * strength

func touch_box(body):
	if body == midas:
		turn_to_gold()
