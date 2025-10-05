# Colony Sim Basics / Citizen Script
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var attributes: CharacterAttributes
@export var mouse_collider: Area2D
@export var info_window: Window
@export var details_label: RichTextLabel
@export var citizen_portrait: Sprite2D


# Player UI Info Variables
var citizen_name: String
var bio: String
var level: int
var full_profile: String
# End player UI variables

## Player State Variables
var inventory: Array[Dictionary] = [{}]
var current_job: Dictionary = {}
var job_progress: float = 0.0 # Time spent on current task
var health: int = 100
var is_working: bool = false
var target_position
var STOPPING_DISTANCE: int = 25
## End player state vars

func find_entry_by_id(array, target_id):
	for entry in array:
		if entry.has("id") and entry["id"] == target_id:
			return entry
		return null # Return null if no entry with the target_id is found

# Function to let NPC claim a job
func _claim_new_job(job_data) -> void:
	print("Pritning from Colony_Citizen.gd")
	print(job_data)
	
	#var entry = find_entry_by_id(SimulationManager.job_queue, job_data["id"])
	#var job_status = SimulationManager.get_status_name(job_data["status"])
	#print("joberino status ", job_status)
	#
	#print('entry', entry)
	if is_working:
		print("This guy is already working")
		return
	current_job = job_data
	is_working = false # make sure we stop working when we move to the job location
	target_position = job_data.location



	pass

func _ready() -> void:
	SimulationManager.job_selected.connect(_claim_new_job)
	citizen_name = attributes.name
	bio = attributes.bio
	level = attributes.base_stats["level"]
	full_profile = str("[b]", citizen_name, "[/b]", "\n", bio, "\n",current_job, "\n", "Level: ", level)
	details_label.text = full_profile
	
	var portrait = attributes.link_to_portrait
	citizen_portrait.texture = portrait
	pass

func _physics_process(delta: float) -> void:
	## Start moving
	if is_working:
		var job_state_to_update = SimulationManager.get_job_by_id(current_job.id)
		job_progress += delta # ticking away the seconds for the job to be done
		job_state_to_update.status = SimulationManager.JobStatus['IN_PROGRESS']
		job_state_to_update.progress = job_progress
		print(job_progress / current_job.duration)
		
		if job_progress >= current_job.duration:
			print('Job done!')
			is_working = false # Finish job
			SimulationManager.job_completed.emit(current_job.id)
			job_progress = 0
			current_job = {}
	
	
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
