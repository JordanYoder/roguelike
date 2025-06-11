class_name Game
extends Node2D

signal player_created(player)

# This script is attached to the Game node.
# This script is the central controller for gameplay. It orchestreates the player, map, input, and enemies

const player_definition: EntityDefinition = preload("res://assets/definitions/entities/actors/entity_definition_player.tres")
const tile_size = 16

# @onready initializes variable once the node is in the scene tree.
# @onready becomes initialized right before _ready is ran
# @onready also references child nodes so they are accessible by the script
@onready var player: Entity
@onready var input_handler: InputHandler = $InputHandler
@onready var map: Map = $Map
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	# Creates the player using the player definition. Adds $Camera2D to the player
	player = Entity.new(null, Vector2i.ZERO, player_definition)
	player_created.emit(player)  # Emits a signal containing a reference to the player as soon as the player is created
	remove_child(camera)
	player.add_child(camera)
	
	# Create the map
	map.generate(player)
	
	# Create the player's initial POV
	map.update_fov(player.grid_position)

	# Initial log message
	MessageLog.send_message.bind(
		"Hello and welcome, adventurer, to yet another dungeon!",
		GameColors.WELCOME_TEXT
	).call_deferred()



func _physics_process(_delta: float) -> void:  # Runs every frame
	# Gets the action for this frame from input_handler
	var action: Action = await input_handler.get_action(player)
	
	if action:
		# If an action is found get the location of the player before the action is performed
		var previous_player_position: Vector2i = player.grid_position
		
		# Perform the action
		if action.perform():
			# Perform enemy turn
			_handle_enemy_turns()
			
			# Update FOV after the player action and enemy action
			map.update_fov(player.grid_position)


func _handle_enemy_turns() -> void:
	# Loop through every entity in the map and if they are alive NPCs then perform the action
	for entity in get_map_data().entities:
		if entity.is_alive() and entity != player:
			entity.ai_component.perform()


func get_map_data() -> MapData:
	# Gets the full map data
	return map.map_data
