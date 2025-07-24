extends Node

signal game_started
signal game_ended
signal scene_transitioned(scene: Node)

const PLAYER_SCENE = preload("res://scenes/prefabs/player.tscn")

var is_game_started: bool = false

func _ready() -> void:
	Network.recieved_packet.connect(_on_packet_recieved)

func scene_transition(new_scene_file: String) -> void:
	get_tree().change_scene_to_file(new_scene_file)
	scene_transitioned.emit(get_tree().current_scene)

func start_game() -> void:
	if is_game_started:
		return
	Network.send_p2p_packet(0,
	{
		"tag": "game_start"
	}
	)
	is_game_started = true
	print("lobby members:\n", Network.lobby_members)
	var target_scene = "res://scenes/levels/game.tscn"
	scene_transition(target_scene)

	spawn_players()
	game_started.emit()

func spawn_players() -> void:
	for member in Network.lobby_members:
		var p = PLAYER_SCENE.instantiate()
		
		p.isLocal = member["steam_id"] == SteamManager.steam_id
		p.steamID = member["steam_id"]
		p.name = member["username"]
		add_child(p)

func _on_packet_recieved(packet_data: Dictionary) -> void:
	if packet_data["tag"] != "game_start" and not is_game_started:
		return
	
	start_game()
