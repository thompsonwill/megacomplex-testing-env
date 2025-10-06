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
var current_action_purpose: String = "JOB" # Can be JOB, PICKUP, or DROP_OFF
var required_pickup_item: Dictionary = {}
var item_resource
## End player state vars

# Do we still need this?  
#func find_entry_by_id(array, target_id):
	#for entry in array:
		#if entry.has("id") and entry["id"] == target_id:
			#return entry
		#return null # Return null if no entry with the target_id is found
		
# Used if there is a cost to the job we want to take.
# Returns true if we have it in our inventory, false if we do not.

# Corrected: Checks all inventory items and checks the count
func check_inventory_for_item(item_to_check: Dictionary) -> bool: # Explicitly return bool
	var required_resource = item_to_check.resource
	var required_count = item_to_check.count
	
	for item in inventory:
		# Check if the resource type matches AND the count is sufficient
		if item_resource == item.type and item.count >= required_count:
			return true # We have enough!
	
	print("You ain't got the required %d of resource %s, pal." % [required_count, required_resource])
	return false # Only return false after checking ALL inventory entries.

func pickup_item(item) -> void:
	pass

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
				current_action_purpose = "JOB"
			else:
				# Next step is to go looking for the resource in the stockpile. 
				# First, add the job_data to our queued_job array
				# Then look for the stockpile with whatever we need
				# Move to that stockpile, pick up item
				# Update inventory in stockpile & NPC inventory
				# Check queued jobs, take the one on the list that we can pay for now 
				print("Adding job to NPC job queue")
				queued_jobs.append(job_data)
				print(queued_jobs)
				print("We're looking for a stockpile")
				if BuildingManager.check_stockpile_for_item(item.resource).success:
					print("stockpile located")
					var stockpile_info = BuildingManager.check_stockpile_for_item(item.resource).stockpile
					required_pickup_item = item
					current_action_purpose = "PICKUP"
					target_position = stockpile_info.position
					is_working = false
					return
					
				
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
			
			match current_action_purpose:
				"JOB":
					# Landed at job site
					if current_job:
						is_working = true
						print("Npc is now beginning work")
				"PICKUP":
					# Landed at stockpile to pick up the item
					_execute_stockpile_pickup()
				"DROP_OFF":
					pass # do this l8r sk8r
				_:
					print("Arrived at target with unknown purpose. RIP")
			
			# Player should only start_working if they land on a job area

		else:
			var direction = global_position.direction_to(target_position)
			velocity = direction * SPEED
	else:
		# If not target, ensure velocity is zero
		velocity = Vector2.ZERO
	move_and_slide()

func _execute_stockpile_pickup() -> void:
	print("_execute_stockpile_pickup")
	print(required_pickup_item)
	item_resource = required_pickup_item.resource
	var item_count = required_pickup_item.count
	
	var found = false
	for item in inventory: # If there's already an item type in the inventory
		print("Item ", item)
		if item.type == item_resource:
			item.count += item_count
			found = true
			break
	if not found: # If we don't have one, pick er up
		inventory.append({
			"type": item_resource,
			"name": "Scrap Metal",
			"count": item_count
		})
	print("Successfully picked up %d of %s. Inventory: %s" % [item_count, item_resource, inventory])
	
	# Clear the variables we cooked up for this
	required_pickup_item = {}
	current_action_purpose = "JOB" # Let's reset our purpose and kick off our queued job
	
	if not queued_jobs.is_empty():
		# Re-claims the first job, which should now pass the inventory check
		var next_job = queued_jobs.pop_front() # Remove from queue
		# call the original claim function to send the NPC to the right spot
		_claim_new_job(next_job)
	else:
		# No job waiting, this guy is a BUM!
		print("pickup complete, not queued jobs. Dude is hanging out. ")
	pass
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
