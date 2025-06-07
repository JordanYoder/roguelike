class_name Component
extends Node

@onready var entity: Entity = get_parent() as Entity  # Get the entity the component will be attached to

func get_map_data() -> MapData:
	return entity.map_data
