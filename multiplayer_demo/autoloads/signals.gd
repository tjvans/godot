extends Node

# multiplayer
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

# ui
signal add_player_to_lobby_ui
signal game_start
