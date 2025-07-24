extends CharacterBody2D

const SPEED: float = 3000.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var avatar_rect: TextureRect = $PlayerCard/PanelContainer/MarginContainer/Hbox/Avatar
@onready var name_label: Label = $PlayerCard/PanelContainer/MarginContainer/Hbox/Name
@onready var player_card: Control = $PlayerCard
@onready var cam: Camera2D = Camera2D.new()
var direction: Vector2
var isLocal: bool = true
var steamID: int = 0

func _ready() -> void:
	Network.recieved_packet.connect(_on_packet_recieved)
	if not isLocal:
		setup_playercard()
		return
	player_card.hide()
	add_child(cam)
	cam.zoom *= 3

func _process(delta: float) -> void:
	if !isLocal:
		return
	update_player()
	direction = Input.get_vector("left", "right", "up", "down").normalized()
	animate()

func _physics_process(delta: float) -> void:
	if !isLocal:
		return
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * SPEED * delta, SPEED * delta)
		velocity.y = move_toward(velocity.y, direction.y * SPEED * delta, SPEED * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		velocity.y = move_toward(velocity.y, 0, SPEED * delta)
	move_and_slide()

func animate() -> void:
	if not direction:
		sprite.play(sprite.animation.replace("run", "idle"))
		return
	
	if direction.y < 0:
		sprite.play("run_up")
	elif direction.y > 0:
		sprite.play("run_down")
	elif direction.x < 0:
		sprite.play("run_left")
	elif direction.x > 0:
		sprite.play("run_right")
	

func setup_playercard() -> void:
	Steam.getPlayerAvatar(Steam.AVATAR_SMALL, steamID)
	await Steam.avatar_loaded
	avatar_rect.texture = ImageTexture.create_from_image(SteamManager.steam_avatar)
	if isLocal:
		name_label.text = SteamManager.steam_username
	else:
		name_label.text = Steam.getFriendPersonaName(steamID)


func _on_packet_recieved(packet_data: Dictionary) -> void:
	if packet_data["tag"] != "player":
		return
	
	print(
		"Recieved Player Packet:\n",
		"PacketSender:\t", packet_data["username"],
		"NEW_POS:\t(", packet_data["x_pos"], ", ", packet_data["y_pos"], ")"
	)
	sync_player(packet_data)


func sync_player(data: Dictionary) -> void:
	if isLocal or data["steam_id"] != steamID:
		return
	
	global_position.x = data["x_pos"]
	global_position.y = data["y_pos"]
	

func update_player() -> void:
	Network.send_p2p_packet(0,
		{
			"tag": "player",
			"x_pos": global_position.x,
			"y_pos": global_position.y
		}, Steam.P2P_SEND_UNRELIABLE_NO_DELAY
	)
