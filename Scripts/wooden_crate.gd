extends CharacterBody2D

@onready var midas = get_tree().get_first_node_in_group("midas")
@onready var tilemap = get_node("../TileMap")
var midas_on_left = false
var midas_on_right = false
var gravity = 500
var crate_on_left = null
var crate_on_right = null
var is_gold = false
var being_pulled = false
var things_on_left = []
var things_on_right = []

@onready var point = get_node("electric point")

func _ready():
	$AnimationPlayer.play("wood")

func _physics_process(delta):
	velocity.x = move_toward(velocity.x, 0, 5)
	if not is_on_floor():
		velocity.y += gravity * delta
	var direction = midas.direction
	var collision = get_last_slide_collision()
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("crate"):
			if ((collision.get_normal().x < -0.05) or (collision.get_normal().x > 0.05)) && collision.get_normal().y <= 0:
				collider.velocity.x = midas.direction * 25
	move_and_slide()

func push_box(strength):
	velocity.x = strength

func touch_box(body):
	if body == midas:
		if $AnimationPlayer.get_current_animation() == "wood":
			$AnimationPlayer.play("gold")
