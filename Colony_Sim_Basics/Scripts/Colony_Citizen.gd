# Colony Sim Basics / Citizen Script
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var attributes: CharacterAttributes
@export var mouse_collider: Area2D
@export var info_window: Window
@export var details_label: RichTextLabel
@export var citizen_portrait: Sprite2D

## Player State Variables
var inventory: Dictionary = {}
var current_job: Dictionary = {}
var health: int = 100
var job_progress: float = 0.0 # Time spent on current task
## End player state vars

func _ready() -> void:
	var citizen_name = attributes.name
	var bio = attributes.bio
	var level = attributes.base_stats["level"]
	var full_profile = str("[b]", citizen_name, "[/b]", "\n", bio, "\n",current_job, "\n", "Level: ", level)
	details_label.text = full_profile
	
	var portrait = attributes.link_to_portrait
	citizen_portrait.texture = portrait
	pass

func _physics_process(delta: float) -> void:
# Where we're going, we don't need gravity. 
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


# Show the citizen's details UI
func _on_mouse_collider_mouse_entered() -> void:
	print("inventory")
	print(inventory)
	print("bio: ", attributes.bio)
	print("Health: ", health)
	pass # Replace with function body.

# Hide the citizen's details UI
func _on_mouse_collider_mouse_exited() -> void:
	pass # Replace with function body.


func _on_mouse_collider_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("left_mouse"):
		info_window.visible = true
	pass # Replace with function body.


func _on_citizen_info_close_requested() -> void:
	info_window.visible = false
	pass # Replace with function body.
