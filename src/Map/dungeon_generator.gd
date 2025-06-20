class_name DungeonGenerator
extends Node

const entity_types = {
	"orc": preload("res://assets/definitions/entities/actors/entity_definition_orc.tres"),
	"troll": preload("res://assets/definitions/entities/actors/entity_definition_troll.tres"),
	"health_potion": preload("res://assets/definitions/entities/items/health_potion_definition.tres")
}

@export_category("Map Dimensions")
@export var map_width: int = 80
@export var map_height: int = 45

@export_category("Rooms RNG")
@export var max_rooms: int = 30
@export var room_max_size: int = 10
@export var room_min_size: int = 6

@export_category("Monsters RNG")
@export var max_monsters_per_room = 2
@export var max_items_per_room = 2



var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()


func generate_dungeon(player:Entity) -> MapData:
	var dungeon := MapData.new(map_width, map_height, player)
	dungeon.entities.append(player)
	
	var rooms: Array[Rect2i] = []
	
	for _try_room in max_rooms:
		var room_width: int = _rng.randi_range(room_min_size, room_max_size)
		var room_height: int = _rng.randi_range(room_min_size, room_max_size)
		
		var x: int = _rng.randi_range(0, dungeon.width - room_width - 1)
		var y: int = _rng.randi_range(0, dungeon.height - room_height - 1)
		
		var new_room := Rect2i(x, y, room_width, room_height)
		
		var has_intersections := false
		for room in rooms:
			# Rect2i.intersects() checks for overlapping points. In order to allow bordering rooms one room is shrunk.
			if room.intersects(new_room.grow(-1)):
				has_intersections = true
				break
		if has_intersections:
			continue
		
		_carve_room(dungeon, new_room)
		
		if rooms.is_empty():
			player.grid_position = new_room.get_center()
			player.map_data = dungeon
		else:
			_tunnel_between(dungeon, rooms.back().get_center(), new_room.get_center())
		
		_place_entities(dungeon, new_room)
		
		rooms.append(new_room)
	
	dungeon.setup_pathfinding()  # Set up pathfinding
	return dungeon


func _carve_room(dungeon: MapData, room: Rect2i) -> void:
	# Creates a room by turning a wall tile into a floor tile
	var inner: Rect2i = room.grow(-1)
	for y in range(inner.position.y, inner.end.y + 1):
		for x in range(inner.position.x, inner.end.x + 1):
			_carve_tile(dungeon, x, y)


func _tunnel_horizontal(dungeon: MapData, y: int, x_start: int, x_end: int) -> void:
	# Tunnels horizontally between rooms
	var x_min: int = mini(x_start, x_end)
	var x_max: int = maxi(x_start, x_end)
	for x in range(x_min, x_max + 1):
		_carve_tile(dungeon, x, y)


func _tunnel_vertical(dungeon: MapData, x: int, y_start: int, y_end: int) -> void:
	# Tunnels vertically between rooms
	var y_min: int = mini(y_start, y_end)
	var y_max: int = maxi(y_start, y_end)
	for y in range(y_min, y_max + 1):
		_carve_tile(dungeon, x, y)


func _tunnel_between(dungeon: MapData, start: Vector2i, end: Vector2i) -> void:
	# Here the actual tunneling occurs
	if _rng.randf() < 0.5:
		_tunnel_horizontal(dungeon, start.y, start.x, end.x)
		_tunnel_vertical(dungeon, end.x, start.y, end.y)
	else:
		_tunnel_vertical(dungeon, start.x, start.y, end.y)
		_tunnel_horizontal(dungeon, end.y, start.x, end.x)


func _carve_tile(dungeon: MapData, x: int, y: int) -> void:
	# Garve this indivual tile by setting the type to floor
	var tile_position = Vector2i(x, y)
	var tile: Tile = dungeon.get_tile(tile_position)
	tile.set_tile_type(dungeon.tile_types.floor)


func _place_entities(dungeon: MapData, room: Rect2i) -> void:
	# Places the entities in the room.
	var number_of_monsters: int = _rng.randi_range(0, max_monsters_per_room)
	var number_of_items: int = _rng.randi_range(0, max_items_per_room)
	
	for _i in number_of_monsters:
		# Create x,y coordinates for monster
		var x: int = _rng.randi_range(room.position.x + 1, room.end.x - 1)
		var y: int = _rng.randi_range(room.position.y + 1, room.end.y - 1)
		var new_entity_position := Vector2i(x, y)
		
		# Check to see if you can place the entity here or if another entity already occupies the spot
		var can_place = true
		for entity in dungeon.entities:
			if entity.grid_position == new_entity_position:
				can_place = false
				break
		
		# Actually place the entity
		if can_place:
			var new_entity: Entity
			if _rng.randf() < 0.8:
				new_entity = Entity.new(dungeon, new_entity_position, entity_types.orc)
			else:
				new_entity = Entity.new(dungeon, new_entity_position, entity_types.troll)
			dungeon.entities.append(new_entity)

	for _i in number_of_items:
		# Create x,y coordinates for item
		var x: int = _rng.randi_range(room.position.x + 1, room.end.x - 1)
		var y: int = _rng.randi_range(room.position.y + 1, room.end.y - 1)
		var new_entity_position := Vector2i(x, y)

		# Check to see if you can place the entity here or if another entity already occupies the spot
		var can_place = true
		for entity in dungeon.entities:
			if entity.grid_position == new_entity_position:
				can_place = false
				break

		# Actually place the item		
		if can_place:
			var new_entity: Entity = Entity.new(dungeon, new_entity_position, entity_types.health_potion)
			dungeon.entities.append(new_entity)