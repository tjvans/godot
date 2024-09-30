extends Node3D

@export var scene_to_load: PackedScene
@export var player_scene: PackedScene
var players_in_lobby: Dictionary


func _ready() -> void:
	Lobby.player_loaded.rpc(1)
	Signals.player_connected.connect(_add_player)
	Signals.player_disconnected.connect(_remove_player)
	Signals.game_start.connect(start_game)


func start_game() -> void:
	# load_game arguments (game_root_path: String, packed_scene_root_node: String, packed_sene_resource_path: String)
	Lobby.load_game.rpc(self.get_path(), str(scene_to_load.get_state().get_node_name(0)), scene_to_load.resource_path)

# Signals
func _add_player(id: int, player_info) -> void:
	if not multiplayer.is_server():
		return
	players_in_lobby = Lobby.players_connected.duplicate()
	players_in_lobby[id]["number"] = Lobby.players_connected.size()
	Signals.add_player_to_lobby_ui.emit(id, players_in_lobby)
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
