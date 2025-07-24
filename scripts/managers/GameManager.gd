extends Node

signal game_started
signal game_ended
signal scene_transitioned(scene: Node)

const PLAYER_SCENE = preload("res://scenes/prefabs/player.tscn")

func scene_transition(new_scene_file: String) -> void:
	get_tree().change_scene_to_file(new_scene_file)
	await get_tree().root.ready  # ensure scene is fully ready
	scene_transitioned.emit(get_tree().current_scene)

func start_game() -> void:
	var target_scene = "res://scenes/levels/game.tscn"
	await scene_transition(target_scene)

	spawn_players()
	
	game_started.emit()

func spawn_players() -> void:
	var current_scene = get_tree().current_scene
	if not current_scene:
		push_error("No current scene loaded!")
		return

	for member in Network.lobby_members:
		var p = PLAYER_SCENE.instantiate()
		
		p.isLocal = member["steam_id"] == SteamManager.steam_id
		current_scene.add_child(p)
