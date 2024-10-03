extends Control


var multiplayer_id: String:
	set(id):
		multiplayer_id = id
		%MultiplayerID.text = id

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer_id = str(multiplayer.get_unique_id())
