extends Control


var multiplayer_id: String:
	set(id):
		multiplayer_id = id
		%MultiplayerID.text = id


func _ready() -> void:
	multiplayer_id = str(multiplayer.get_unique_id())
