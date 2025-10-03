# Main

extends Node2D

var dragging: bool = false
var selected: Array = []
var drag_start: Vector2 = Vector2.ZERO
var select_rect = RectangleShape2D.new()

# REMOVED: The signal is no longer needed.
# signal move_command(target_position: Vector2)

func handle_clear_selections() -> void:
	for item in selected:
		if item.collider.has_node("Sprite2D"):
			var char_sprite = item.collider.get_node("Sprite2D")
			char_sprite.modulate = Color.WHITE
	selected.clear()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("right_mouse") and selected.size() > 0:
		print("trying to clear")
		handle_clear_selections()
	if event.is_action_pressed("left_mouse") and selected.size() > 0:
		var mouse_pos = get_global_mouse_position()
		
		# CHANGED: Instead of emitting a signal, we now loop through the
		# selected units and call their 'move_to' function directly.
		for item in selected:
			var npc = item.collider
			# Check if the collider has the function before calling to be safe.
			if npc.has_method("move_to"):
				npc.move_to(mouse_pos)
		
		# This part handles deselecting the units after the command is given.
		handle_clear_selections()
		return

	# --- The rest of the script remains the same ---
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			if selected.size() == 0:
				dragging = true
				drag_start = event.position
		elif dragging:
			dragging = false
			queue_redraw()
			var drag_end = event.position
			select_rect.size = (drag_end - drag_start).abs()
			
			var space = get_world_2d().direct_space_state
			var query = PhysicsShapeQueryParameters2D.new()
			query.set_shape(select_rect)
			query.transform = Transform2D(0, (drag_end + drag_start) / 2)
			selected = space.intersect_shape(query)
			
			for item in selected:
				if item.collider.has_node("Sprite2D"):
					var char_sprite = item.collider.get_node("Sprite2D")
					char_sprite.modulate = Color(0.664, 0.559, 0.012, 1.0)
			
	if event is InputEventMouseMotion and dragging:
		queue_redraw()

func _draw():
	if dragging:
		draw_rect(Rect2(drag_start, get_global_mouse_position() - drag_start), Color(0.653, 0.122, 0.221, 0.5), false, 2.0)
