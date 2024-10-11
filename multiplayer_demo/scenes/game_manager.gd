extends Node3D
class_name GameManager

@export var level_to_load: PackedScene
@export var player_scene: PackedScene

const PLAYER_COLORS: Array[Color] = [Color.CRIMSON, Color.BLUE, Color.SEA_GREEN, Color.YELLOW]

var players_in_lobby: Dictionary


func _ready() -> void:
	Signals.player_connected.connect(_add_player)
	Signals.player_disconnected.connect(_remove_player)
	Signals.load_level.connect(_load_level)
	Globals.players_spawn = $Players

func start_game() -> void:
	print("All players have loaded the level")
	_spawn_players()

func _spawn_players() -> void:
	var players_to_spawn = players_in_lobby.keys()
	for player in players_to_spawn:
		var new_player_scene = player_scene.instantiate()
		new_player_scene.multiplayer_id = player
		new_player_scene.multiplayer_info = players_in_lobby[player]
		$Players.add_child(new_player_scene, true)
		new_player_scene.orb.mesh_color = players_in_lobby[player]["color"]

# Signals
func _add_player(id: int, player_info) -> void:
	players_in_lobby = Lobby.players_connected.duplicate()
	players_in_lobby[id]["number"] = Lobby.players_connected.size()
	players_in_lobby[id]["color"] = PLAYER_COLORS[Lobby.players_connected.size() - 1]
	Signals.add_player_to_lobby_ui.emit(id, players_in_lobby)

func _remove_player(id: int) -> void:
	if players_in_lobby.has(id):
		players_in_lobby.erase(id)
		print("Remaining connected players: ", players_in_lobby)
	if not $Players.has_node(str(id)):
		push_error("Player scene with id: ", id, " not found")
		return
	$Players.get_node(str(id)).queue_free()

func _load_level() -> void:
	# load_game arguments (game_root_path: String, packed_scene_root_node: String, packed_sene_resource_path: String)
	Lobby.load_game(self.get_path(), str(level_to_load.get_state().get_node_name(0)), level_to_load.resource_path)
	Lobby.load_game.rpc(self.get_path(), str(level_to_load.get_state().get_node_name(0)), level_to_load.resource_path)
