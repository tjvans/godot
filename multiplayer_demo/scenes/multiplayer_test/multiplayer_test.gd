extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Lobby.player_loaded.rpc(Globals.game_root)
