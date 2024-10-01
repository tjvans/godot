extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Lobby.player_loaded.rpc(Globals.game_root.get_path())
	position_players()

func position_players() -> void:
	var players = get_tree().get_current_scene().get_node(Globals.players_spawn.get_path()).get_children()
	var spawn_points = $PlayerSpawnPoints.get_children()
	for player in players:
		player.global_transform = spawn_points[player.get_index()].global_transform
