extends HBoxContainer

@export var player_colour: Color:
	set(colour):
		player_colour = colour
		$PlayerColour.color = colour
@export var multiplayer_id: int:
	set(id):
		multiplayer_id = id
		$MultiplayerID.text = str(id)
@export var player_name: String:
	set(name):
		player_name = name
		$PlayerName.text = str(name)
