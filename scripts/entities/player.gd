extends RigidBody3D

@onready var camera = $TwistPivot/PitchPivot/Camera3D

# ty https://www.youtube.com/watch?v=sVsn9NqpVhg

# runs when node enters scene tree for the first time
func _ready() -> void:
	pass

# called every frame, delta is elapsed time since prev. frame
# delta allows variations between machines
func _process(delta: float) -> void:
	# _handle_movement(delta)
	pass

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# var input = Input.get_action_strength("ui_up")
	# apply_central_force(input * Vector3.FORWARD * 1200.0 * delta)
	
	var input := Vector3.ZERO
	
	input.x = Input.get_axis("ui_left", "ui_right")
	input.z = Input.get_axis("ui_up", "ui_down")
	
	if input == Vector3.ZERO:
		return
	
	# map keyboard controls to relatively move based on camera (45deg/cardinal movement only)
	var camera_basis = camera.global_transform.basis
	
	var vertical = camera_basis.z
	var horizontal = camera_basis.x
	
	# unused/ignored axis
	vertical.y = 0
	horizontal.y = 0
	
	vertical = vertical.normalized()
	horizontal = horizontal.normalized()
	
	# works with both keyboard and joystick controls 🔥
	var dir = (vertical * input.z + horizontal * input.x).normalized()
	
	# fix traveling on slopes
	var slope_normal := Vector3.UP
	
	# for each contacted bodies
	for i in range(get_contact_count()):
		var normal = state.get_contact_local_normal(i)
		
		if normal.dot(Vector3.UP) > 0.5: # 
			slope_normal = normal
	
	var dir2 = dir.slide(slope_normal).normalized()
	
	# multi * 30 for running | 17 for regular
	apply_central_force(dir2 * 17)
	
	# apply an extra y axis force depending on the slope angle
	var slope_angle = acos(slope_normal.dot(Vector3.UP))
	if slope_angle > 0.0 and slope_angle < deg_to_rad(60):
		# multi * 10 for running | 5 for regular
		var boost = (slope_angle / deg_to_rad(45)) * 5
		apply_central_force(Vector3.UP * boost)
		# print_debug("adding upward force to assist slope movement", boost)
		# print_debug("angle is", slope_angle)
	
