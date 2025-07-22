extends Control

@onready var lobby_id_field: LineEdit = %LobbyIDField
@onready var lobby_list: ItemList = %LobbyLists
@onready var lobby: HSplitContainer = $PanelContainer/MarginContainer/Lobby
@onready var lobby_discovery: HSplitContainer = $PanelContainer/MarginContainer/LobbyDiscovery
@onready var members_vbox: VBoxContainer = $PanelContainer/MarginContainer/Lobby/Members
@onready var start: Button = $PanelContainer/MarginContainer/Lobby/Control/Start

# For mapping lobby list indices to lobby IDs
var lobby_ids: Array = []

func _ready() -> void:
	lobby.hide()
	lobby_discovery.show()
	lobby_list.item_activated.connect(_on_lobby_item_activated)
	Network.connect("member_list_updated", _on_member_list_updated)
	Steam.lobby_match_list.connect(_on_lobby_list_requested)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	update_lobby_list()

func _on_host_pressed() -> void:
	Network.create_lobby()

func _on_join_with_id_pressed() -> void:
	var lobby_id = int(lobby_id_field.text)
	Network.join_lobby(lobby_id)

func update_lobby_list() -> void:
	lobby_list.clear()
	lobby_ids.clear()
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()

func _on_refresh_lobbies_pressed() -> void:
	update_lobby_list()

func _on_lobby_list_requested(lobbies: Array) -> void:
	lobby_list.clear()
	lobby_ids.clear()
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "name")
		if lobby_name == "":
			lobby_name = str(lobby)
		var idx = lobby_list.add_item(lobby_name)
		lobby_ids.append(lobby) # Store the lobby ID for this item

func _on_lobby_item_activated(index: int) -> void:
	if index >= 0 and index < lobby_ids.size():
		var lobby_id = lobby_ids[index]
		Network.join_lobby(lobby_id)

func _on_lobby_joined(this_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		lobby.show()
		lobby_discovery.hide()
		
		if Network.is_host:
			start.show()
		else:
			start.hide()
		Network.get_lobby_members() # Will trigger member_list_updated signal

func _on_lobby_chat_update(lobby_id: int, change_id: int, making_change_id: int, chat_state: int) -> void:
	if lobby.visible:
		Network.get_lobby_members() # Will trigger member_list_updated signal

func _on_member_list_updated(members: Array) -> void:
	# Clear previous members
	for child in members_vbox.get_children():
		child.queue_free()
	# Add member cards
	for member in members:
		create_member_card(member)

func create_member_card(member: Dictionary) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 64)
	members_vbox.add_child(panel)

	var hbox := HBoxContainer.new()
	panel.add_child(hbox)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	# Info
	var vbox := VBoxContainer.new()
	hbox.add_child(vbox)

	var name_label := Label.new()
	name_label.text = member["username"]
	vbox.add_child(name_label)

	var id_label := Label.new()
	id_label.text = "SteamID: %s" % str(member["steam_id"])
	vbox.add_child(id_label)



# Optional: A leave lobby function
func _on_leave_lobby_pressed() -> void:
	Steam.leaveLobby(Network.lobby_id)
	lobby.hide()
	lobby_discovery.show()
	update_lobby_list()


func _on_start_pressed() -> void:
	hide()
	GameManager.start_game()
