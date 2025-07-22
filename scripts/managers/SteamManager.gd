extends Node

var steam_id: int = 0
var steam_username: String = ""
var isSteamRunning: bool = false

func _init() -> void:
	OS.set_environment("SteamAppID", str(480))
	OS.set_environment("SteamGameID", str(480))
	
	Steam.steamInit()
	
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()
	Steam.allowP2PPacketRelay(true)


func _process(delta: float) -> void:
	Steam.run_callbacks()
