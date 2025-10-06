extends Node

## Main Game State Variables
var global_oxygen_level: int = 100 # max 100, min 0 (that means we dead)
var power_output: int = 10 #kw? whats a lot or a little? Who cares for now
var resource_inventory: Dictionary = {} # ScrapMetal, WiringSpools, ProcessedData, etc. 

# Global Enum Definitions
enum JobStatus {AVAILABLE, CLAIMED, IN_PROGRESS, BLOCKED}
enum JobType {REPAIR, SCAVENGE, GET_RESOURCE}
## Resource Enums
enum ResourceType {CONSUMABLE, SCRAP_METAL}

var job_queue: Array[Dictionary] = [{
	"id": "job_001",
	"type": JobType.REPAIR,
	"location": Vector2i(686,80), # make sure you fill this in with the real zone
	"duration": 2.0, # <-- add required work time (in seconds)
	"status": JobStatus.AVAILABLE,
	"assigned_npc_id": null,
	"progress": 0, 
	"cost": [{"resource": ResourceType.SCRAP_METAL, "count": 1}] # <-- however many resources it costs to do this 
	#"reward": {} Is there a reward? How much will they *get* for scavenging? They can add this to their inventory
}]
## End main game state variables



# Signals
signal job_selected # fired from the job screen UI
signal job_completed(index: int) # ensure we can update the jobs array when the job is done
signal look_for_item(item)


# Helper function to get job data
func get_job_by_id(id: String) -> Variant:
	for job in job_queue:
		if job.id == id:
			return job
		else:
			return "No matching job found"
	return null # idk if this ever fires


func _on_job_completed(id: String)-> void:
	var job = get_job_by_id(id) # Get the full job JSON by its ID
	var job_to_remove = job_queue.find(job) # Get the index of this job in the job_queue array
	job_queue.remove_at(job_to_remove) # kill that mamajama
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	job_completed.connect(_on_job_completed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
