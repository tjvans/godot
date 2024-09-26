extends HBoxContainer

@export var player_colour: Color:
	set(colour):
		$PlayerColour.color = colour
@export var multiplayer_id: int:
	set(id):
		$MultiplayerID.text = str(id)
@export var player_name: String:
	set(name):
		$PlayerName.text = str(name)
