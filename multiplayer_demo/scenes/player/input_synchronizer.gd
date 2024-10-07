extends MultiplayerSynchronizer

@export var spring_arm: SpringArm3D
@export var mouse_sensitivity: float = 0.005
@export var input_direction: Vector2
@export var camera_direction: Vector3


func _ready() -> void:
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
		spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -90.0, 30.0)
		spring_arm.rotation.y -= event.relative.x * mouse_sensitivity
	if Input.is_action_just_pressed("ui_accept"):
		if get_multiplayer_authority() == multiplayer.get_unique_id():
			jump.rpc()

func _physics_process(delta: float) -> void:
	input_direction = align_input_to_player_orientation()
	camera_direction = Vector3(input_direction.x, 0, input_direction.y).rotated(Vector3.UP, spring_arm.rotation.y)

func align_input_to_player_orientation() -> Vector2:
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var input_vector3d = Vector3(input_vector.x, 0, input_vector.y)
	var player_basis = $"..".global_transform.basis
	var rotated_input = player_basis * input_vector3d
	return Vector2(rotated_input.x, rotated_input.z)

@rpc("call_local")
func jump():
	if multiplayer.is_server():
		$"../PlayerOrb".do_jump = true
