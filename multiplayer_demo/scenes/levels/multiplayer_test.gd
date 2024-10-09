extends Node3D


var players_moved: bool = false

func _ready() -> void:
	Lobby.player_loaded.rpc(Globals.game_root.get_path())

func _process(delta: float) -> void:
	if Lobby.players_loaded == Lobby.players_connected.size()\
	 and players_moved == false:
		position_players()
		position_players.rpc()
		players_moved = true

@rpc("authority", "reliable")
func position_players() -> void:
	var player_nodes = Globals.players_spawn.get_children()
	if player_nodes.size() == Lobby.players_connected.size():
		var spawn_points = $PlayerStartPositions.get_children()
		for player in player_nodes:
			player.orb.set_process_mode(false)
			player.orb.set_physics_process(false)
			player.orb.velocity = Vector3.ZERO
			player.global_transform = spawn_points[player.get_index()].global_transform
			await get_tree().physics_frame
			player.orb.set_process_mode(true)
			player.orb.set_physics_process(true)
	else:
		push_error("Player nodes not found")
