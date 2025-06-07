class_name Entity
extends Sprite2D

enum AIType {NONE, HOSTILE}  # Defines possible AI behaviors for this entity
enum EntityType {CORPSE, ITEM, ACTOR}  # Describes what kind of object this is. Used for rendering order



var grid_position: Vector2i: # This is a setter for the grid position
	set(value):
		grid_position = value
		position = Grid.grid_to_world(grid_position)
var _definition: EntityDefinition
var entity_name: String
var blocks_movement: bool
var type: EntityType: # This is a setter for the entity's type
	set(value):
		type = value
		z_index = type
var map_data: MapData

var fighter_component: FighterComponent
var ai_component: BaseAIComponent

func _init(map_data: MapData, start_position: Vector2i, entity_definition: EntityDefinition) -> void:
	centered = false  # Disable's Sprite2D centering to align with the grid
	grid_position = start_position
	self.map_data = map_data
	set_entity_type(entity_definition) # Initialize entity type


func set_entity_type(entity_definition: EntityDefinition) -> void:
	# Gets the definition resource data and stores it for access
	_definition = entity_definition
	type = _definition.type
	blocks_movement = _definition.is_blocking_movement
	entity_name = _definition.name
	texture = entity_definition.texture
	modulate = entity_definition.color
	
	# Adds the ai component to this entity
	match entity_definition.ai_type:
		AIType.HOSTILE:
			ai_component = HostileEnemyAIComponent.new()
			add_child(ai_component)
	
	# Adds the fighter_definition to this entity
	if entity_definition.fighter_definition:
		fighter_component = FighterComponent.new(entity_definition.fighter_definition)
		add_child(fighter_component)


func move(move_offset: Vector2i) -> void:
	map_data.unregister_blocking_entity(self) # Set self entity to not block
	grid_position += move_offset  # Perform the actual move
	map_data.register_blocking_entity(self)  # Re set the self entity to block


func is_blocking_movement() -> bool:
	return blocks_movement


func get_entity_name() -> String:
	return entity_name


func get_entity_type() -> int:
	return _definition.type


func is_alive() -> bool:
	return ai_component != null
