extends Node

var steam_id: int = 0
var steam_username: String = ""
var steam_avatar: Image
var isSteamRunning: bool = false

func _init() -> void:
	OS.set_environment("SteamAppID", str(480))
	OS.set_environment("SteamGameID", str(480))
	
	Steam.steamInit()
	
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()
	Steam.allowP2PPacketRelay(true)
	
	Steam.avatar_loaded.connect(_on_avatar_loaded)
	Steam.getPlayerAvatar(Steam.AVATAR_SMALL, steam_id)


func _process(delta: float) -> void:
	Steam.run_callbacks()

func _on_avatar_loaded(id, size, buffer) -> void:
	steam_avatar = Image.create_from_data(size, size, false, Image.FORMAT_RGBA8, buffer)
