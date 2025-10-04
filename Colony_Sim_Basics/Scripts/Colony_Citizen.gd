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
var is_working: bool = false
var target_position
var STOPPING_DISTANCE: int = 25
## End player state vars

# Function to let NPC claim a job
func _claim_new_job(job_data) -> void:

	current_job = job_data
	is_working = false # make sure we stop working when we move to the job location
	target_position = job_data.location
	
	# This is ugly, make this better
	var citizen_name = attributes.name
	var bio = attributes.bio
	var level = attributes.base_stats["level"]
	var full_profile = str("[b]", citizen_name, "[/b]", "\n", bio, "\n","Job: ", current_job['name'], "\n", "Level: ", level)
	details_label.text = full_profile
	# Just wrapping this shitty code in comments to remember to update it later


	pass

func _ready() -> void:
	SimulationManager.job_selected.connect(_claim_new_job)
	var citizen_name = attributes.name
	var bio = attributes.bio
	var level = attributes.base_stats["level"]
	var full_profile = str("[b]", citizen_name, "[/b]", "\n", bio, "\n",current_job, "\n", "Level: ", level)
	details_label.text = full_profile
	
	var portrait = attributes.link_to_portrait
	citizen_portrait.texture = portrait
	pass

func _physics_process(delta: float) -> void:
	## Start moving
	if is_working:
		job_progress += delta # ticking away the seconds for the job to be done
		print("working working")
		
		if job_progress >= current_job.duration:
			print('Job done!')
			is_working = false # Finish job
			SimulationManager.job_completed.emit(current_job.index)
	
	
	if target_position != null:
		var distance = global_position.distance_to(target_position)
		
		if distance < STOPPING_DISTANCE:
			velocity = Vector2.ZERO
			target_position = null
			print("Arrived at target location.")
			is_working = true
			print("NPC is now beginning work.")
		else:
			var direction = global_position.direction_to(target_position)
			velocity = direction * SPEED
	else:
		# If not target, ensure velocity is zero
		velocity = Vector2.ZERO
	move_and_slide()


# Show the citizen's details UI
func _on_mouse_collider_mouse_entered() -> void:
	#print("inventory")
	#print(inventory)
	#print("bio: ", attributes.bio)
	#print("Health: ", health)
	pass # Replace with function body.

# Hide the citizen's details UI
func _on_mouse_collider_mouse_exited() -> void:
	pass # Replace with function body.


# Show and hide the citizen info UI
func _on_mouse_collider_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("left_mouse"):
		info_window.visible = true

func _on_citizen_info_close_requested() -> void:
	info_window.visible = false
