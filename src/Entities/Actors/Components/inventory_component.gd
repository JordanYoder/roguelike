class_name InventoryComponent
extends Component

var items: Array[Entity]
var capacity: int

func _init(capacity: int) -> void:
    items = []
    self.capacity = capacity


func drop(item: Entity) -> void:
    items.erase(item)  # Remove the item
    var map_data = get_map_data()
    map_data.entities.append(item)  # Append the item to entities array
    map_data.entity_placed.emit(item)  # Attach to map node
    item.map_data = map_data  # The current map, as we can have different maps for different levels
    item.grid_position = entity.grid_position  # Drop at player's location
    MessageLog.send_message("You dropped the %s." % item.get_entity_name(), Color.WHITE)