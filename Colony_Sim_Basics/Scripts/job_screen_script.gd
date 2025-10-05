# Jobs Screen UI Component
extends Control
@export var jobs_list_component: ItemList
var jobs_list: Array[Dictionary]

#var job_queue: Array[Dictionary] = [{
	#"type": "Repair",
	#"location": Vector2i(0,0), # make sure you fill this in with the real zone
	#"duration": 5.0, # <-- add required work time (in seconds)
#}]

# Called when the node enters the scene tree for the first time.
# add_item(text: String, icon: Texture2D = null, selectable: bool = true)

func _populate_list(index: int) -> void:
	jobs_list_component.remove_item(index)


func _ready() -> void:
	jobs_list = SimulationManager.job_queue
	var loop_index = 0
	for job in jobs_list:
		var job_type_int = job.type # enum stores the job type as an integer, we need to get the name
		var job_type = SimulationManager.JobType.keys()[job_type_int]

		jobs_list_component.add_item(job_type, null, true)
		jobs_list_component.set_item_metadata(loop_index, {"job_id": job.id})
		loop_index += 1
	#SimulationManager.job_completed.connect(_populate_list)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_jobs_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	
	var job_name = jobs_list_component.get_item_text(index)
	var job_metadata = jobs_list_component.get_item_metadata(index)
	var job = SimulationManager.get_job_by_id(job_metadata.job_id) # This is the direct job entry from Simulation Manager
	
	if job.status == SimulationManager.JobStatus['AVAILABLE']: # Need to work in a way to check if our npc is already working
		print("Job is available, npc is claiming")
		job.status = SimulationManager.JobStatus['CLAIMED'] # Let's see if this actually claims the job
		SimulationManager.job_selected.emit(job)
	
	#job_data['name'] = job_name
	#job_data['index'] = index
	#SimulationManager.job_selected.emit(job_data)
	#print(job_metadata)
	pass # Replace with function body.
