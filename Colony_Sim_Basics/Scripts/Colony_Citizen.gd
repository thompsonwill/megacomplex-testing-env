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
var inventory: Array = [{
	"type": SimulationManager.ResourceType.CONSUMABLE,
	"name": "Beer",
	"count": 2,
}]
var current_job: Dictionary = {}
var queued_jobs: Array = []
var job_progress: float = 0.0 # Time spent on current task
var health: int = 100
var is_working: bool = false
var target_position
var STOPPING_DISTANCE: int = 25
## End player state vars

# Do we still need this?  
#func find_entry_by_id(array, target_id):
	#for entry in array:
		#if entry.has("id") and entry["id"] == target_id:
			#return entry
		#return null # Return null if no entry with the target_id is found
		
# Used if there is a cost to the job we want to take.
# Returns true if we have it in our inventory, false if we do not.
func check_inventory_for_item(item_to_check: Dictionary) -> Variant:
	print(item_to_check)
	for item in inventory: # loop through our inventory to check if we have what we need
		if item_to_check.resource == item.type: # if required resrouce type == the item in our inventory type...
			return true
		else:
			print("You ain't got this one, pal.")
			return false
	return




# Function to let NPC claim a job
# Need to clean up the code that actually sets the job details (current_job, is_working, target_position)
# We repeat that in a few places.
func _claim_new_job(job_data) -> void:
	print(job_data)
	
	if job_data.cost.size() > 0:
		for item in job_data.cost:
			# Check if we have the item in our inventory
			if check_inventory_for_item(item):
				print("we got this one! Let's goooo")
				current_job = job_data
				is_working = false # make sure we stop working when we move to the job location
				target_position = job_data.location
			else:
				# Next step is to go looking for the resource in the stockpile. 
				# First, add the job_data to our queued_job array
				# Then look for the stockpile with whatever we need
				# Move to that stockpile, pick up item
				# Update inventory in stockpile & NPC inventory
				# Check queued jobs, take the one on the list that we can pay for now 
				print("We're looking for a stockpile")
				BuildingManager.check_stockpile_for_item(item.resource)
				
	else: # this job is free to complete. So generous of our capitalist overlords. 
		print("No cost to this job")
		if is_working:
			print("This guy is already working")
			return
		current_job = job_data
		is_working = false # make sure we stop working when we move to the job location
		target_position = job_data.location


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
