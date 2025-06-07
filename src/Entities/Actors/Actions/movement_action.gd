class_name MovementAction
extends ActionWithDirection


func perform() -> void:
	var map_data: MapData = get_map_data()  # Get the map data
	var destination_tile: Tile = map_data.get_tile(get_destination())  # From the map data, get the tile of the destination
	
	# Early returns if the tile is not accessible
	if not destination_tile or not destination_tile.is_walkable():
		return
	if get_blocking_entity_at_destination():
		return
		
	# We have now validated that we can move to this tile. Perform the actual move
	entity.move(offset)
