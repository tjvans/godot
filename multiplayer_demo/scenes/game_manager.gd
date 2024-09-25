extends Node3D

@export var scene_to_load: PackedScene


func _ready() -> void:
	Lobby.player_loaded.rpc(1)
	Signals.game_start.connect(_start_game)


func _start_game() -> void:
	Lobby.load_game(self, scene_to_load)
