extends CharacterBody3D

@export var speed = 5.0
@export var acceleration = 4.0
@export var jump_speed = 8.0

func _ready() -> void:
	pass

func _apply_movement(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_speed

	var input_dir: Vector2 = %InputSynchronizer.input_direction
	var dir = %InputSynchronizer.camera_direction
	velocity = lerp(velocity, dir * speed, acceleration * delta)

	move_and_slide()

func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		_apply_movement(delta)
