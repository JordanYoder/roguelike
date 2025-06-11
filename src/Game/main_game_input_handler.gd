extends BaseInputHandler

const directions = {
	"move_up": Vector2i.UP,
	"move_down": Vector2i.DOWN,
	"move_left": Vector2i.LEFT,
	"move_right": Vector2i.RIGHT,
	"move_up_left": Vector2i.UP + Vector2i.LEFT,
	"move_up_right": Vector2i.UP + Vector2i.RIGHT,
	"move_down_left": Vector2i.DOWN + Vector2i.LEFT,
	"move_down_right": Vector2i.DOWN + Vector2i.RIGHT,
}

const inventory_menu_scene = preload("res://src/GUI/InventoryMenu/inventory_menu.tscn")


func get_action(player: Entity) -> Action:
	var action: Action = null
	
	for direction in directions:
		if Input.is_action_just_pressed(direction):
			var offset: Vector2i = directions[direction]
			action = BumpAction.new(player, offset.x, offset.y)
	
	if Input.is_action_just_pressed("wait"):
		action = WaitAction.new(player)

	if Input.is_action_just_pressed("view_history"):
		get_parent().transition_to(InputHandler.InputHandlers.HISTORY_VIEWER)

	if Input.is_action_just_pressed("pickup"):
		action = PickupAction.new(player)

	if Input.is_action_just_pressed("drop"):
		var selected_item: Entity = await get_item("Select an item to drop", player.inventory_component)
		action = DropItemAction.new(player, selected_item)

	if Input.is_action_just_pressed("activate"):
		var selected_item: Entity = await get_item("Select an item to use", player.inventory_component)
		action = ItemAction.new(player, selected_item)
	
	if Input.is_action_just_pressed("quit") or Input.is_action_just_pressed("ui_back"):
		action = EscapeAction.new(player)
	
	return action


func get_item(window_title: String, inventory: InventoryComponent) -> Entity:
	var inventory_menu: InventoryMenu = inventory_menu_scene.instantiate()  # Instantiate inventory menu
	add_child(inventory_menu)  # Add as a child
	inventory_menu.build(window_title, inventory)  # Initialize inventory
	get_parent().transition_to(InputHandler.InputHandlers.DUMMY)  # Switch to dummy handler

	 # Stop the funciton's execution until inventory_menu emits the item_selected signal. 
	 #That is the reason why we used call_deferred() in the build() function. 
	 # If we didn’t the inventory menu would emit that signal and only then would we stop everything until we get that signal. 
	 # If we weren’t careful here an empty inventory could lock our game.
	var selected_item: Entity = await inventory_menu.item_selected 
	await get_tree().physics_frame
	get_parent().call_deferred("transition_to", InputHandler.InputHandlers.MAIN_GAME)
	return selected_item
