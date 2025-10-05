# Stockpile

extends Node2D
@export var inventory_label: Label
var inventory: Array
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inventory = SimulationManager.stockpile_1_inventory
	inventory_label.text = str(inventory)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
