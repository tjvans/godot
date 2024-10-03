extends Node3D


func _ready() -> void:
	Lobby.player_loaded.rpc(Globals.game_root.get_path())
	if multiplayer.is_server():
		position_players.rpc()

@rpc("call_local", "reliable")
func position_players() -> void:
	var players = get_tree().get_current_scene().get_node(Globals.players_spawn.get_path()).get_children()
	var spawn_points = $PlayerSpawnPoints.get_children()
	for player in players:
		player.player_orb.set_physics_process(false)
		player.global_transform = spawn_points[player.get_index()].global_transform
		player.player_orb.velocity = Vector3.ZERO
		await get_tree().physics_frame
		player.player_orb.set_physics_process(true)
