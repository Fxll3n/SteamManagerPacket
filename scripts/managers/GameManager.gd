extends Node

signal game_started
signal game_ended
signal scene_transitioned(scene: Node)

const PLAYER_SCENE = preload("res://addons/uState/example/player.tscn")

func scene_transition(new_scene_file: String) -> void:
	get_tree().change_scene_to_file(new_scene_file)
	await get_tree().root.ready  # ensure scene is fully ready
	scene_transitioned.emit(get_tree().current_scene)

func start_game() -> void:
	var target_scene = "res://addons/uState/example/example.tscn"
	await scene_transition(target_scene)

	spawn_players()
	
	game_started.emit()

func spawn_players() -> void:
	var current_scene = get_tree().current_scene
	if not current_scene:
		push_error("No current scene loaded!")
		return

	for member in Network.lobby_members:
		var is_local_player = member["steam_id"] == SteamManager.steam_id
		var player = PLAYER_SCENE.instantiate()
		player.id = member["steam_id"]
		player.isLocal = is_local_player
		if is_local_player:
			player.name = "LocalPlayer"
		else:
			player.name = "RemotePlayer_%s" % member["username"]

		get_tree().add_child(player)
