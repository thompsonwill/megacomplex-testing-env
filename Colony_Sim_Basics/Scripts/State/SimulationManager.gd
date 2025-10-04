extends Node

## Main Game State Variables
var global_oxygen_level: int = 100 # max 100, min 0 (that means we dead)
var power_output: int = 10 #kw? whats a lot or a little? Who cares for now
var resource_inventory: Dictionary = {} # ScrapMetal, WiringSpools, ProcessedData, etc. 

var job_queue: Array[Dictionary] = [{
	"type": "Repair",
	"location": Vector2i(686,80), # make sure you fill this in with the real zone
	"duration": 2.0, # <-- add required work time (in seconds)
	#"cost": {ScrapMetal: 1} <-- however many resources it costs to do this 
},{
	"type": "Scavenging",
	"location": Vector2i(220,409), # make sure you fill this in with the real zone
	"duration": 10.0, # <-- add required work time (in seconds)
	#"cost": null <-- however many resources it costs to do this 
	#"reward": {} Is there a reward? How much will they *get* for scavenging? They can add this to their inventory
}]
## End main game state variables

# Signals
signal job_selected # fired from the job screen UI
signal job_completed(index: int) # ensure we can update the jobs array when the job is done


func _on_job_completed(index: int)-> void:
	job_queue.remove_at(index) # nuke the finished job from the array 
	print("removing job from list ", index)
	print(job_queue) 
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	job_completed.connect(_on_job_completed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
