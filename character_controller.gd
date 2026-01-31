extends CharacterBody2D
class_name CharacterController

var move_speed := 500
var jump_speed := 500

var is_jumping := false

func _physics_process(delta: float) -> void:
	
	var move_dir := 0.0
	if Input.is_action_pressed("move_right"):
		move_dir += 1
	if Input.is_action_pressed("move_left"):
		move_dir -= 1
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y -= jump_speed
		is_jumping = true
	elif is_jumping:
		if is_on_floor():
			is_jumping = false
		elif not Input.is_action_pressed("jump"):
			if velocity.y < 0:
				velocity.y = 0
	
	velocity.x = move_dir * move_speed
	velocity += get_gravity() * delta
	
	move_and_slide()
