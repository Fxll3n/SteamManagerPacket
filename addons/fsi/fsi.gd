@tool
extends EditorPlugin


func _enable_plugin() -> void:
	# Add autoloads here.
	add_autoload_singleton("NetworkManager", "res://addons/fsi/managers/NetworkManager.gd")
	add_autoload_singleton("SteamManager", "res://addons/fsi/managers/SteamManager.gd")


func _disable_plugin() -> void:
	# Remove autoloads here.
	remove_autoload_singleton("NetworkManager")
	remove_autoload_singleton("SteamManager")


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
