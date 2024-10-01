extends Node3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var multiplayer_id: int = 1:
	set(id):
		multiplayer_id = id
		self.name = str(id)
		%InputSynchronizer.set_multiplayer_authority(id)
var multiplayer_info

func _ready() -> void:
	if multiplayer.get_unique_id() == multiplayer_id:
		$Camera3D.make_current()
	else:
		$Camera3D.current = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		pass
