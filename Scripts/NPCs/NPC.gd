# NPC Script

extends CharacterBody2D

const SPEED = 300.0
const STOPPING_DISTANCE = 15.0 # How close to get before stopping.

# NEW: A variable to store the destination. 'null' means we have no target.
var target_position

#@onready var main_node = get_tree().get_nodes_in_group("Emitter")[0]

func _ready() -> void:
	# Connect to the new signal from the Main node.
	#main_node.move_command.connect(_on_move_command)
	pass
# NEW: A public function that can be called directly by other scripts.
# This replaces the signal handler function.
func move_to(new_target_pos: Vector2) -> void:
	target_position = new_target_pos
	
# This function simply sets the target. The real work is in _physics_process.
#func _on_move_command(new_target_pos: Vector2) -> void:
	#target_position = new_target_pos

func _physics_process(delta: float) -> void:
	if target_position != null:
		var direction = global_position.direction_to(target_position)
		var distance = global_position.distance_to(target_position)

		if distance < STOPPING_DISTANCE:
			velocity = Vector2.ZERO
			target_position = null
		else:
			velocity = direction * SPEED
	
	move_and_slide()
