extends Node3D

@onready var game_scene_root = $GameScenes
@onready var ui_root = $UI


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Lobby.player_loaded.rpc(1)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
