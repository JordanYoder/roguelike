class_name MovementAction
extends ActionWithDirection


func perform() -> bool:
	var destination: Vector2i = get_destination()

	var map_data: MapData = get_map_data()  # Get the map data
	var destination_tile: Tile = map_data.get_tile(destination)  # From the map data, get the tile of the destination
	
	# Early returns if the tile is not accessible
	if not destination_tile or not destination_tile.is_walkable() or get_blocking_entity_at_destination():
		if entity == map_data.player:
			MessageLog.send_message("That way is blocked", GameColors.IMPOSSIBLE)
		return false	
		
	# We have now validated that we can move to this tile. Perform the actual move
	entity.move(offset)
	return true
