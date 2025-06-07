class_name HostileEnemyAIComponent
extends BaseAIComponent


var path: Array = []

func perform() -> void:
	var target: Entity = get_map_data().player
	var target_grid_position: Vector2i = target.grid_position
	var offset: Vector2i = target_grid_position - entity.grid_position  # Relative position from entity to player
	var distance: int = max(abs(offset.x), abs(offset.y))  # Distance between entity and player
	
	if get_map_data().get_tile(entity.grid_position).is_in_view:
		if distance <= 1:
			return MeleeAction.new(entity, offset.x, offset.y).perform()
		
		path = get_point_path_to(target_grid_position)  # Request a new path from entity to player
		path.pop_front()  # Remove first element of path, which is the tile the enemy stands on
	
	if not path.is_empty():  # If the next movement tile is empty
		var destination := Vector2i(path[0])  # Go to next tile
		if get_map_data().get_blocking_entity_at_location(destination):  # If a blocking entity is found
			return WaitAction.new(entity).perform()  # Wait for next turn, so it 'queues' behind the entity
		path.pop_front()
		var move_offset: Vector2i = destination - entity.grid_position  # Calculate the move
		return MovementAction.new(entity, move_offset.x, move_offset.y).perform()  # Perform the move
	
	return WaitAction.new(entity).perform()
