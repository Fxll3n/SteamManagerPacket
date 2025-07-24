class_name Chat
extends CanvasLayer

@onready var chat_history: RichTextLabel = %ChatHistory
@onready var chat_line: LineEdit = %ChatLine

func _ready() -> void:
	chat_line.text_submitted.connect(_on_message_submited)
	Network.recieved_packet.connect(_on_packet_recieved)

func send_chat_message(message: String) -> void:
	if not message and message == null:
		return
	
	Network.send_p2p_packet(0,
		{
			"tag": "message",
			"chat_message": message
		}
	)

func print_to_chat(message: String) -> void:
	chat_history.append_text(message + "\n")

func _on_message_submited(new_text: String) -> void:
	send_chat_message(new_text)
	chat_line.text = ""
	print_to_chat("[color=cyan][b]You[/b]:[/color]\t%s" % new_text)

func _on_packet_recieved(packet_data: Dictionary) -> void:
	if packet_data["tag"] != "message":
		return
	
	print_to_chat("[color=blue][b]%s[/b]:[/color]\t%s" % [packet_data["username"], packet_data["chat_message"]])
