class_name ActionWithDirection
extends Action

var offset: Vector2i


func _init(entity: Entity, dx: int, dy: int) -> void:
	super._init(entity)  # Calls the base to initialize entity
	offset = Vector2i(dx, dy) # The offset is where the entity is looking to move


func get_destination() -> Vector2i:
	# Gets the location the entity is targeting
	return entity.grid_position + offset


func get_blocking_entity_at_destination() -> Entity:
	# Asks the map for any entity that is blocking the tile at the destination
	return get_map_data().get_blocking_entity_at_location(get_destination())


func get_target_actor() -> Entity:
	# Calculates the target using get_destination, then queries the map to retrieve any actor on that tile
	return get_map_data().get_actor_at_location(get_destination())

