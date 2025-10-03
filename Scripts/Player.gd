# Player Script

extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func get_input():
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_direction * SPEED

func _physics_process(delta: float) -> void:
	get_input()
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	# Handle jump.


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	#if input_direction:
		#velocity.x = input_direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
