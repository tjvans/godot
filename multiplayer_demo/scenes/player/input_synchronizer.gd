extends MultiplayerSynchronizer

@export var spring_arm: SpringArm3D
@export var mouse_sensitivity: float = 0.005
var input_direction
var camera_direction


func _ready() -> void:
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
	input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	camera_direction = Vector3(input_direction.x, 0, input_direction.y).rotated(Vector3.UP, spring_arm.rotation.y)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
		spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -90.0, 30.0)
		spring_arm.rotation.y -= event.relative.x * mouse_sensitivity

func _physics_process(delta: float) -> void:
	input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	camera_direction = Vector3(input_direction.x, 0, input_direction.y).rotated(Vector3.UP, spring_arm.rotation.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
