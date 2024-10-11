extends Node3D


@export var multiplayer_id: int = 1:
	set(id):
		multiplayer_id = id
		self.name = str(id)
		%InputSynchronizer.set_multiplayer_authority(id)
@export var multiplayer_info: Dictionary
@onready var orb: CharacterBody3D = $PlayerOrb

func _ready() -> void:
	if multiplayer.get_unique_id() == multiplayer_id:
		$PlayerOrb/SpringArm3D/Camera3D.make_current()
