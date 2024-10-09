extends HBoxContainer

@export var player_color: Color:
	set(color):
		player_color = color
		$PlayerColor.color = color
@export var multiplayer_id: int:
	set(id):
		multiplayer_id = id
		$MultiplayerID.text = str(id)
@export var player_name: String:
	set(name):
		player_name = name
		$PlayerName.text = str(name)
