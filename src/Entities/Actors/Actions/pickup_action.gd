class_name PickupAction
extends Action

func perform() -> bool:
    var inventory: InventoryComponent = entity.inventory_component
    var map_data: MapData = get_map_data()

    for item in map_data.get_items():
        
        # Is there a item on this tile
        if entity.grid_position == item.grid_position:

            # Cannot add to inventory as inventory is full
            if inventory.items.size() >= inventory.capacity:
                MessageLog.send_message("Your inventory is full", GameColors.IMPOSSIBLE)
                return false
            
            # Remove item from map and append to the inventory
            map_data.entities.erase(item)  # Remove from map's list of items
            item.get_parent().remove_child(item)  # Remove from map Node
            inventory.items.append(item)
            MessageLog.send_message("You picked up the %s!" %item.get_entity_name(), Color.WHITE)
            return true

    # There is no item on this tile
    MessageLog.send_message("There is nothing to pick up.", GameColors.IMPOSSIBLE)
    return false

