extends Node

# Building type definitions
var buildings_by_type: Dictionary = {
	"Stockpile": [], # Array of locations/references for all stockpiles
	"Dormitory": []
}

# Maybe this should get moved later, figure it out
var stockpile_1_inventory = [{
	"type": SimulationManager.ResourceType.SCRAP_METAL,
	"name": "Scrap Metal",
	"count": 10,
	"location": "Stockpile_1"
}]
# End stockpile testing


func check_stockpile_for_item(item_type: SimulationManager.ResourceType) -> void:
	# Harcoding stockpile array because we're looking for shit in there
	for stockpile in buildings_by_type['Stockpile']:
		if stockpile.inventory.size() > 0:
			for item in stockpile.inventory:
				if item.type == item_type:
					print("Item located, sickem boys")
					print(item)
				else:
					print("Doesn't seem to be one of those items laying around.")
		else:
			print("Inventory is completely empty, champ")
	pass
	
func register_building(type: String, position: Vector2i, area: Rect2, node: PackedScene ) -> void:
	# Check if the building type exists in our dictionary, if it does, add it to the list
	if buildings_by_type.has(type):
		buildings_by_type[type].append({"position": position, "area": area, "node": node, "inventory": stockpile_1_inventory})
	pass
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get the area the building covers for pathfinding destination
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
