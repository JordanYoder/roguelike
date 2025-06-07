class_name Action
extends RefCounted  
# RefCounted has Godot internally trakck how many references or points are pointing to it. 
# If no more variables are referencing it Godot fress it automatically (which does not happen with Node)

var entity: Entity


func _init(entity: Entity) -> void:
	# Set the entity that is performing the action
	self.entity = entity


func perform() -> void:
	pass


func get_map_data() -> MapData:
	# Get the entitie's map data
	return entity.map_data
