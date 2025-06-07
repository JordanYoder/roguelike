class_name BaseAIComponent
extends Component


func perform() -> void:
	pass
	

func get_point_path_to(destination: Vector2i) -> PackedVector2Array:
	# Gives a path from one point to another
	return get_map_data().pathfinder.get_point_path(entity.grid_position, destination)
	
