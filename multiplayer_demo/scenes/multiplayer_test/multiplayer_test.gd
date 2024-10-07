extends Node3D


var players_moved: bool = false

func _ready() -> void:
	Lobby.player_loaded.rpc(Globals.game_root.get_path())

func _process(delta: float) -> void:
	if Lobby.players_loaded == 4 and players_moved == false:
		position_players.rpc()
		players_moved = true

@rpc("call_local", "reliable")
func position_players() -> void:
	var player_nodes = Globals.players_spawn.get_children()
	if player_nodes.size() == Lobby.players_connected.size():
		var spawn_points = $PlayerSpawnPoints.get_children()
		for player in player_nodes:
			player.player_orb.set_physics_process(false)
			player.player_orb.velocity = Vector3.ZERO
			player.global_transform = spawn_points[player.get_index()].global_transform
			player.player_orb.set_process_mode(true)
			await get_tree().physics_frame
			player.player_orb.set_physics_process(true)
	else:
		push_error("Player Nodes Not Found")
