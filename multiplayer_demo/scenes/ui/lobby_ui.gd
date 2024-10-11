extends Control


@export var lobby_element_scene: PackedScene
@export var lobby_list: VBoxContainer


func _ready() -> void:
	Signals.add_player_to_lobby_ui.connect(_on_add_player_to_lobby)
	Signals.player_disconnected.connect(_on_player_disconnected)

# Signals
func _on_add_player_to_lobby(id: int, players_connected) -> void:
	if not multiplayer.is_server():
		return
	if lobby_list.has_node(str(id)):
		return
	if id in players_connected:
		var player_lobby_element = lobby_element_scene.instantiate()
		player_lobby_element.multiplayer_id = id
		player_lobby_element.name = str(id)
		player_lobby_element.player_name = players_connected[id]["name"]
		player_lobby_element.player_color = players_connected[id]["color"]
		lobby_list.add_child(player_lobby_element)

func _on_player_disconnected(id: int) -> void:
	lobby_list.get_node(str(id)).queue_free()
