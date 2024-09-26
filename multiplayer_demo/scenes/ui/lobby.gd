extends Control

@export var lobby_element_scene: PackedScene
@export var lobby_list: VBoxContainer

var lobby_colours: Array[Color] = [Color.CRIMSON, Color.BLUE, Color.SEA_GREEN, Color.YELLOW]


func _ready() -> void:
	Signals.player_connected.connect(_on_player_connected)
	Signals.player_disconnected.connect(_on_player_disconnected)

# Signals
func _on_player_connected(id: int, player_info) -> void:
	if not multiplayer.is_server():
		return
	if lobby_list.has_node(str(id)):
		return
	var player_lobby_element = lobby_element_scene.instantiate()
	player_lobby_element.name = str(id)
	var player_colour = player_info["number"] - 1
	player_lobby_element.player_colour = lobby_colours[player_colour]
	player_lobby_element.multiplayer_id = id
	player_lobby_element.player_name = player_info["name"]
	lobby_list.add_child(player_lobby_element)

func _on_player_disconnected(id: int) -> void:
	lobby_list.get_node(str(id)).queue_free()
