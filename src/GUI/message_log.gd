class_name MessageLog
extends ScrollContainer

var last_message: Message = null

@onready var message_list: VBoxContainer = $"%MessageList"


func _ready() -> void:
	SignalBus.message_sent.connect(add_message)


func add_message(text: String, color: Color) -> void:
	if (last_message != null and last_message.plain_text == text):
		# Checks if last message is the same as this message and if so iterates count
		last_message.count += 1
	else:
		var message := Message.new(text, color)  # Create a new message
		last_message = message
		message_list.add_child(message)  # Add message to list
		await get_tree().process_frame  # Used to see the next frame and the current UI sizing
		ensure_control_visible(message)  # Scrolls the log if necessary



static func send_message(text: String, color: Color) -> void:
	SignalBus.message_sent.emit(text, color)