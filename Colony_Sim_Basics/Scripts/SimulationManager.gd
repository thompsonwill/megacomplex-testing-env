extends Node

## Main Game State Variables
var global_oxygen_level: int = 100 # max 100, min 0 (that means we dead)
var power_output: int = 10 #kw? whats a lot or a little? Who cares for now
var resource_inventory: Dictionary = {} # ScrapMetal, WiringSpools, ProcessedData, etc. 
var job_queue: Array[Dictionary] = [{
	"type": "Repair",
	"location": Vector2i(0,0), # make sure you fill this in with the real zone
	"duration": 5.0, # <-- add required work time (in seconds)
	#"cost": {ScrapMetal: 1} <-- however many resources it costs to do this 
}]
## End main game state variables

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(global_oxygen_level)
	print(power_output)
	print(resource_inventory)
	print(job_queue)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
