extends Node3D

@export var scene_to_load: PackedScene
@export var player_scene: PackedScene



func _ready() -> void:
	Lobby.player_loaded.rpc(1)
	Signals.player_connected.connect(_add_player)
	Signals.player_disconnected.connect(_remove_player)
	
	Signals.game_start.connect(_start_game)


func _start_game() -> void:
	Lobby.load_game(self, scene_to_load)


# Signals
func _add_player(id: int, player_info) -> void:
	if not multiplayer.is_server():
		return
	var player: CharacterBody3D = player_scene.instantiate()
	player.multiplayer_id = id
	player.multiplayer_info = player_info
	
	#var player_controller: MultiPlayerController = multi_player_controller_scene.instantiate()
	#player_controller.multiplayer_id = id
	#table.players.add_child(player_controller, true)
	#
	#var player_data = PlayerData.new()
	#player_data.multiplayer_id = id
	#player_data.name = multiplayer_info.name
	#player_data.seat_number = MultiplayerGlobals.connected_players.size()
	#player_controller.player.setup(player_data, table)
	#
	#player_controller.player.turn_done.connect(_start_next_turn)
	#player_controllers.append(player_controller)
	#players.append(player_controller.player)


func _remove_player() -> void:
	pass
