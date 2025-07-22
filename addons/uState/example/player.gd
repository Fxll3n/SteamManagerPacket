# Player.gd - Enhanced packet-based sync with interpolation
extends CharacterBody2D

@export var max_gravity: float = 980
@onready var statemachine: uMachine = $uMachine
@onready var anim_sprite: AnimatedSprite2D = %AnimatedSprite2D

var id: int = 0
var isLocal: bool = true

# For smooth interpolation
var target_position: Vector2
var target_velocity: Vector2

func _ready() -> void:
	Network.player_updated.connect(_on_player_update)
	target_position = global_position
	target_velocity = velocity

func _input(event: InputEvent) -> void:
	if not isLocal:
		return
	if statemachine.current_state.has_method("handle_input"):
		statemachine.current_state.handle_input(event)

func _process(delta: float) -> void:
	if isLocal:
		sync_player_state()
	else:
		interpolate_remote_player(delta)

func _physics_process(delta: float) -> void:
	if not isLocal:
		return  # Only process physics for local player
		
	if not is_on_floor():
		velocity.y = clamp(velocity.y + max_gravity * delta, 0, max_gravity)
	move_and_slide()

func sync_player_state() -> void:
	
	Network.send_p2p_packet(0, {
		"tag": "player",
		"steam_id": id,
		"state": statemachine.current_state.name,
		"position": global_position,
		"velocity": velocity,
		"animation": anim_sprite.animation,
	})

func interpolate_remote_player(delta: float) -> void:
	# Smoothly interpolate to target position
	var lerp_speed = 10.0  # Adjust for smoothness vs responsiveness
	global_position = global_position.lerp(target_position, lerp_speed * delta)
	velocity = velocity.lerp(target_velocity, lerp_speed * delta)

func _on_player_update(player_data: Dictionary) -> void:
	if isLocal:
		return  # NEVER update local player from the network
	if player_data.get("steam_id", 0) != id:
		return
	
	# Update interpolation targets
	target_position = player_data.get("position", target_position)
	target_velocity = player_data.get("velocity", target_velocity)
	
	# Update state immediately (no interpolation needed)
	var state_name: String = player_data.get("state", "")
	if statemachine.current_state.name != state_name and statemachine.has_state(state_name):
		statemachine.change_state(state_name)
	
	# Update animation immediately
	var anim_name: String = player_data.get("animation", "")
	if anim_sprite.animation != anim_name and anim_name != "":
		anim_sprite.play(anim_name)
