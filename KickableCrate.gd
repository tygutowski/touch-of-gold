class_name Crate
extends CharacterBody2D

@export var fall_speed := 200.0
@export var tile_size := 8
@export var fall_check_distance := 1

@onready var crate_group := get_tree().get_nodes_in_group("crate")

var is_moving := false

func _physics_process(delta):
	if is_moving:
		return

	if not is_on_floor():
		velocity.y += fall_speed * delta
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func get_crate_line(direction: int) -> Array:
	var line = []
	var current = self

	while current:
		line.append(current)
		current = get_next_crate(current, direction)

	return line

func kick(direction: int):
	if is_moving: 
		return

	var line = get_crate_line(direction)
	if line.size() == 0: return

	# Too many crates? Do nothing
	if line.size() > 3: return

	# Check if last crate in chain can move
	var last = line[-1]
	var target_pos = last.global_position + Vector2(direction, 0) * tile_size

	if !can_move_to(target_pos):
		return

	# If stacked, move all in column above last
	var stack = get_stack_above(last)

	for crate in stack:
		crate.move_to(crate.global_position + Vector2(direction, 0) * tile_size)


func get_next_crate(from: Crate, direction: int) -> Crate:
	for other in crate_group:
		if other == from: continue
		if other.global_position == from.global_position + Vector2(direction, 0) * tile_size:
			return other
	return null

func get_stack_above(base: Crate) -> Array:
	var stack = [base]
	var pos = base.global_position

	for other in crate_group:
		if other.global_position == pos - Vector2(0, tile_size):
			stack += get_stack_above(other)
	return stack

func can_move_to(target_pos: Vector2) -> bool:
	for other in crate_group:
		if other.global_position == target_pos:
			return false
	return true

func move_to(target_pos: Vector2):
	is_moving = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", target_pos, 0.125)
	tween.tween_callback(stop_moving_crate)

func stop_moving_crate():
	is_moving = false
