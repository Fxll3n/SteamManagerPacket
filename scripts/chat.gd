extends CanvasLayer

const CHAT_SCENE: PackedScene = preload("uid://ciawip7fyqq47")

@onready var chat_rtl: RichTextLabel
@onready var chat_line: LineEdit

var chat_history: Array[Dictionary] = []
var chat_view: Control

func _ready() -> void:
	chat_view = CHAT_SCENE.instantiate()
	add_child(chat_view)
	
	chat_rtl = chat_view.get_node("%ChatHistory")
	chat_line = chat_view.get_node("%ChatLine")
	
	chat_line.text_submitted.connect(_on_message_submited)
	Network.recieved_packet.connect(_on_packet_recieved)

func send_message(message: String, author: String = Steam.getPersonaName()) -> void:
	if not message and message == null:
		return
	
	Network.send_p2p_packet(
		Network.ALL_TARGETS,
		{
			"tag": "message",
			"author": author,
			"message": message
		}
	)
	chat_history.append(
		{
			"author": author,
			"message": message
		}
	)
	update_chat()

func update_chat() -> void:
	chat_rtl.text = ""
	for msg in chat_history:
		chat_rtl.append_text("[color=cyan][b]%s:[/b][/color] %s\n" % [msg["author"], msg["message"]])

func _on_message_submited(new_text: String) -> void:
	send_message(new_text)
	chat_line.text = ""

func _on_packet_recieved(packet_data: Dictionary) -> void:
	if packet_data["tag"] != "message":
		return
	
	chat_history.append(
		{
			"author": packet_data["author"],
			"message": packet_data["message"]
		}
	)
	update_chat()

func setup_console_commands() -> void:
	LimboConsole.register_command(
		send_message,
		"msg",
		"send a message in chat."
	)
