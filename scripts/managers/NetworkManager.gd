extends Node

signal member_list_updated(members: Array)
signal recieved_packet(packet_data: Dictionary)

const PACKET_READ_LIMIT: int = 32
const LOBBY_MEMBER_LIMIT: int = 2

var is_host: bool = false
var lobby_id: int = 0
var lobby_members: Array = []

func _init() -> void:
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.p2p_session_request.connect(_on_p2p_session_request)
	
func _ready() -> void:
	Chat.hide()

func _process(delta: float) -> void:
	if not Steam.isSteamRunning():
		print("[Network] Steam not running.")
		return
	
	read_all_p2p_packets()

#region METHODS
func create_lobby() -> void:
	if lobby_id != 0:
		push_warning(str("[Network] User is already in a lobby:\t%s" % lobby_id))
		return
	is_host = true
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, LOBBY_MEMBER_LIMIT)
	Chat.show()

func join_lobby(this_lobby_id: int) -> void:
	Steam.joinLobby(this_lobby_id)
	Chat.show()

func get_lobby_members() -> Array:
	lobby_members.clear()
	var num_of_lobby_members: int = Steam.getNumLobbyMembers(lobby_id)
	
	for member in range(0, num_of_lobby_members):
		var member_id: int = Steam.getLobbyMemberByIndex(lobby_id, member)
		var member_username: String = Steam.getFriendPersonaName(member_id)
		
		lobby_members.append({
			"steam_id": member_id,
			"username": member_username
		})
	emit_signal("member_list_updated", lobby_members)
	return lobby_members

func send_p2p_packet(packet_data: Dictionary, this_target: int = 0, send_type: int = 0) -> void:
	var channel = 0
	
	var this_data: PackedByteArray
	
	packet_data["steam_id"] = Steam.getSteamID()
	packet_data["username"] = Steam.getPersonaName()
	
	this_data.append_array(var_to_bytes(packet_data))
	
	match this_target:
		0:
			if lobby_members.size() > 1:
				for member in lobby_members:
					if member["steam_id"] != SteamManager.steam_id:
						Steam.sendP2PPacket(member["steam_id"], this_data, send_type, channel)
		_:
			Steam.sendP2PPacket(this_target, this_data, send_type, channel)

func read_p2p_packet() -> void:
	var packet_size = Steam.getAvailableP2PPacketSize()
	
	if packet_size > 0:
		print("[Network] Recieved a packet.")
		var this_packet: Dictionary = Steam.readP2PPacket(packet_size)
		#var packet_sender: int = this_packet["steam_remote_id"]
		var packet_code: PackedByteArray = this_packet["data"]
		var readable_data: Dictionary = bytes_to_var(packet_code)
		
		if readable_data.has("tag"):
			print("[Network] Packet contains a tag.")
			recieved_packet.emit(readable_data)
			match readable_data["tag"]:
				"handshake":
					print("[Network] Acknowledged handshake from %s (AKA %s)" % [readable_data["steam_id"], readable_data["username"]])
					print("[Network] %s has joined the lobby." % readable_data["username"])
					Chat.chat_history.append(
						{
							"author": "[color=red]SERVER[/color]",
							"message": "%s has joined the lobby." % readable_data["username"]
						}
					)
					Chat.update_chat()
					get_lobby_members()

func read_all_p2p_packets(read_count: int = 0) -> void:
	if read_count > PACKET_READ_LIMIT:
		return
	
	if Steam.getAvailableP2PPacketSize() > 0:
		read_p2p_packet()
		read_all_p2p_packets(read_count + 1)

func make_p2p_handshake() -> void:
	send_p2p_packet({
		"tag" : "handshake"
	})
	print("[Network] Initiated Handshake.")
#endregion
#region SIGNALS
func _on_lobby_created(connect: int, this_lobby_id: int) -> void:
	if connect != 1:
		push_warning("[Network] Lobby creation failed with error code:\t%s" % connect)
		return
	
	lobby_id = this_lobby_id
	Steam.setLobbyJoinable(lobby_id, true)
	Steam.setLobbyData(lobby_id, "name", str("%s's Lobby" % SteamManager.steam_username))
	var set_relay: bool = Steam.allowP2PPacketRelay(true)
	print("[Network] Lobby created with id:\t%s" % lobby_id)

func _on_lobby_joined(this_lobby_id: int, _permisions: int, _locked: bool, response: int) -> void:
	if response != Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		push_warning("Failed to join lobby %s with error code:\t%s", [this_lobby_id, response])
		return
	lobby_id = this_lobby_id
	print("[Network] Sucessfully joined lobby:\t%s" % this_lobby_id)
	get_lobby_members()
	make_p2p_handshake()

func _on_p2p_session_request(remote_id: int) -> void:
	var this_requester: String = Steam.getFriendPersonaName(remote_id)
	
	Steam.acceptP2PSessionWithUser(remote_id)
#endregion
