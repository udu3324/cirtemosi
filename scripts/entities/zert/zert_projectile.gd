extends RayCast3D

# ty bramwell!! https://www.youtube.com/watch?v=vGpFwaLUG4U

@export var speed := 5.0

func _physics_process(delta: float) -> void:
	position += global_basis * Vector3.FORWARD * speed * delta
	target_position = Vector3.FORWARD * speed * delta
	force_raycast_update()
	#var collider = get_collider()
	if is_colliding():
		global_position = get_collision_point()
		set_physics_process(false)

func cleanup() -> void:
	queue_free()
