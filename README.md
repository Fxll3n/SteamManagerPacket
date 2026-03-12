# Fxll3n's Steam Integration (FSI)

A Godot 4 plugin that provides Steam lobby management, P2P packet networking, and player management using the [GodotSteam GDExtension](https://github.com/GodotSteam/GodotSteam).

> ⚠️ **This plugin requires the GodotSteam GDExtension and is NOT a standalone plugin.**  
> You must install the GodotSteam GDExtension separately before using this plugin.

---

## Requirements

| Dependency | Version | Notes |
|---|---|---|
| [Godot Engine](https://godotengine.org/) | 4.4+ | |
| [GodotSteam GDExtension](https://github.com/GodotSteam/GodotSteam) | Latest | **Must be installed manually** |
| Steam Client | Any | Must be running when testing |

---

## Installation

### 1. Install the GodotSteam GDExtension

This plugin depends on GodotSteam. Follow the official GodotSteam installation instructions:

- Download the GDExtension from the [GodotSteam releases page](https://github.com/GodotSteam/GodotSteam/releases).
- Place the `addons/godotsteam/` folder into your project's `addons/` directory.
- Enable the extension in your project (it should be detected automatically).

### 2. Install This Plugin

**Via the Godot Asset Library (recommended):**

1. Open your Godot project.
2. Go to **AssetLib** tab.
3. Search for **Fxll3n's Steam Integration**.
4. Click **Download** and then **Install**.

**Manually:**

1. Copy the `addons/fsi/` folder into your project's `addons/` directory.
2. In Godot, open **Project → Project Settings → Plugins**.
3. Enable **Fxll3n's Steam Integration**.

### 3. Configure Your App ID

Set your Steam App ID in `steam_appid.txt` in the root of your project (use `480` for Spacewar during development):

```
480
```

---

## Features

- **SteamManager** autoload — Initialises Steam, exposes `steam_id`, `steam_username`, and `steam_avatar`.
- **NetworkManager** autoload — Creates and joins Steam lobbies, sends/receives P2P packets, handles handshakes.

### Autoloads Added by This Plugin

| Singleton | Path | Description |
|---|---|---|
| `SteamManager` | `addons/fsi/managers/SteamManager.gd` | Steam initialisation and player info |
| `NetworkManager` | `addons/fsi/managers/NetworkManager.gd` | Lobby and P2P networking |

---

## Usage

### Creating a Lobby

```gdscript
NetworkManager.create_lobby()
```

### Joining a Lobby

```gdscript
NetworkManager.join_lobby(lobby_id)
```

### Sending a P2P Packet

```gdscript
NetworkManager.send_p2p_packet(
    NetworkManager.ALL_TARGETS,
    {
        "tag": "my_tag",
        "data": "hello"
    }
)
```

### Receiving Packets

```gdscript
func _ready() -> void:
    NetworkManager.recieved_packet.connect(_on_packet_received)

func _on_packet_received(packet_data: Dictionary) -> void:
    print(packet_data["tag"])
```

---

## Demo

A working demo scene is included under `addons/fsi/demo/`. It demonstrates:

- Lobby creation and joining
- P2P packet sending (chat messages, game start)
- Player spawning synced over Steam P2P

The demo also uses [LimboConsole](https://github.com/limbonaut/limbo_console) for in-game debugging.

---

## License

This plugin is released under the [MIT License](LICENSE).

The GodotSteam GDExtension is a separate project with its own license — see the [GodotSteam repository](https://github.com/GodotSteam/GodotSteam) for details.

