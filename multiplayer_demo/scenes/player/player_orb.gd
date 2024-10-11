extends CharacterBody3D


@export var mesh_color: Color = Color.WHITE:
	set(color):
		mesh_color = color
		$MeshInstance3D.mesh.material.albedo_color = color
@export var _is_on_floor: bool = true
@export var speed = 5.0
@export var acceleration = 4.0
@export var jump_speed = 8.0
@export var do_jump: bool = false


func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		_is_on_floor = is_on_floor()
		_apply_movement(delta)

func _apply_movement(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if do_jump and is_on_floor():
		velocity.y = jump_speed
		do_jump = false
	
	var dir: Vector3 = %InputSynchronizer.camera_direction
	velocity = lerp(velocity, dir * speed, acceleration * delta)
	
	move_and_slide()
