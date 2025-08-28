extends RigidBody3D

@onready var agent = $NavigationAgent3D

var target_reached = true
var roaming = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

# thank you bramwell!! https://www.youtube.com/watch?v=2W4JP48oZ8U
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	agent.set_target_position(Globals.player_pos)
	
	# too far, start roaming
	if agent.distance_to_target() > 5:
		return
	
	# too close, stop
	if agent.distance_to_target() < 1.5 and !roaming:
		return
	
	var dir = (agent.get_next_path_position() - global_transform.origin).normalized()
	
	# fix traveling on slopes
	var slope_normal := Vector3.UP
	
	# for each contacted bodies
	for i in range(get_contact_count()):
		var normal = state.get_contact_local_normal(i)
		
		if normal.dot(Vector3.UP) > 0.5: # 
			slope_normal = normal
	
	var dir2 = dir.slide(slope_normal).normalized()
	
	if state.linear_velocity.length() > 2:
		state.linear_velocity = state.linear_velocity.normalized() * 3.5
	
	apply_central_force(dir2 * 7)
	
	# apply an extra y axis force depending on the slope angle
	var slope_angle = acos(slope_normal.dot(Vector3.UP))
	if slope_angle > 0.0 and slope_angle < deg_to_rad(60):
		var boost = (slope_angle / deg_to_rad(45)) * 5
		apply_central_force(Vector3.UP * boost)


func _on_navigation_agent_3d_target_reached() -> void:	
	# target_reached = true
	roaming = false
	
	print_debug("reached target!")
	
	_generate_roam_point_target()

func _generate_roam_point_target():
	var random_pos := Vector3.ZERO
	random_pos.x = randf_range(-5.0, 5.0)
	random_pos.y = randf_range(-5.0, 5.0)
	
	random_pos = random_pos + global_transform.origin
	
	agent.set_target_position(random_pos)
