extends Node

# Autoload named Lobby

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players_connected = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {"name": "Name"}

var local_ip = _get_local_ip()

var loaded_ids: Array = []
var players_loaded = 0


func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _get_local_ip() -> String:
	if OS.get_name() == "Linux":
		return IP.get_local_addresses()[0]
	else:
		return IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")), IP.TYPE_IPV4)


func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	players_connected[1] = player_info
	Signals.player_connected.emit(1, player_info)


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null


# When the server decides to start the game from a UI scene
@rpc("authority", "reliable")
func load_game(game_root_path: String, packed_scene_root_node: String, packed_sene_resource_path: String):
	var game_root_node = get_node(game_root_path)
	if game_root_node.has_node(packed_scene_root_node):
		push_error("Level already loaded")
		return
	var packed_scene = load(packed_sene_resource_path)
	var scene = packed_scene.instantiate()
	game_root_node.add_child(scene)

# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded(game_root_node):
	if multiplayer.is_server():
		var sender_id: int = multiplayer.get_remote_sender_id()
		if not loaded_ids.has(sender_id):
			loaded_ids.append(sender_id)
			players_loaded = loaded_ids.size()
			if players_loaded == players_connected.size():
				get_node(game_root_node).start_game()

# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)


@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players_connected[new_player_id] = new_player_info
	Signals.player_connected.emit(new_player_id, new_player_info)


func _on_player_disconnected(id):
	players_connected.erase(id)
	Signals.player_disconnected.emit(id)


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players_connected[peer_id] = player_info
	Signals.player_connected.emit(peer_id, player_info)


func _on_connected_fail():
	multiplayer.multiplayer_peer = null


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players_connected.clear()
	Signals.server_disconnected.emit()
