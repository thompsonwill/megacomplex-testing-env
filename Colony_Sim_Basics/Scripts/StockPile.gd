# Stockpile

extends Node2D
@export var tiles: TileMapLayer
@export var inventory_label: Label
@export var building_type: String = "Stockpile"
@onready var stockpile_scene: PackedScene = preload("res://Colony_Sim_Basics/StockPile.tscn")

var inventory: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var building_area = get_rect()
	var building_area: Rect2 = tiles.get_used_rect()
	
	# Register building with the global manager
	BuildingManager.register_building(building_type, global_position, building_area, stockpile_scene)

	inventory_label.text = str(BuildingManager.stockpile_1_inventory) # Crude test, update this later
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Player arriving at ", building_type)
	pass # Replace with function body.
