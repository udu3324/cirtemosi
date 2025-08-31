extends RigidBody3D

@onready var agent = $NavigationAgent3D
@onready var enemt_zone: Area3D = get_parent().get_child(0)

@onready var model = $enemt

var target_reached = true

var roaming = false
var chasing = false

var stuck_time := 0.0

func _ready() -> void:
	_generate_roam_point_target()

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if agent.is_navigation_finished():
		stuck_time = 0.0
	else:
		stuck_time += delta
	
	if stuck_time > 6.0:
		# print_debug("agent found stuck, regenerating new path")
		
		roaming = false
		chasing = false
		
		_generate_roam_point_target()
	

# thank you bramwell!! https://www.youtube.com/watch?v=2W4JP48oZ8U
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	
	# agent is close enough to player!
	if global_transform.origin.distance_to(Globals.player_pos) < 5:
		agent.set_target_position(Globals.player_pos)
		chasing = true
		roaming = false
	
	# agent is too far from player, reset chase
	if global_transform.origin.distance_to(Globals.player_pos) > 5 and chasing:
		chasing = false
		enemt_zone.global_transform.origin = global_transform.origin
		_generate_roam_point_target()
		
	# dont need to move if its finised reaching target
	if agent.is_navigation_finished():
		return
	
	# agent is chasing and is too close to player!
	if global_transform.origin.distance_to(Globals.player_pos) < 1.3 and chasing:
		pass # not sure if i need this
	
	# below is rotational stuff, dont mess with it too
	if chasing:
		_face_to_vector3(Globals.player_pos)
	
	if roaming:
		_face_to_velocity()
	
	# below is all the physics stuff, it does not need to be touched i promise :100:
	
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
	
	var force = 16 if chasing else 10
	apply_central_force(dir2 * force)
	
	# apply an extra y axis force depending on the slope angle
	var slope_angle = acos(slope_normal.dot(Vector3.UP))
	if slope_angle > 0.0 and slope_angle < deg_to_rad(60):
		var boost = (slope_angle / deg_to_rad(45)) * 7
		apply_central_force(Vector3.UP * boost)
		


func _on_navigation_agent_3d_target_reached() -> void:
	if chasing:
		return
	
	# print_debug("reached target!")
	
	roaming = false
	
	await get_tree().create_timer(randi_range(1, 5)).timeout
	
	_generate_roam_point_target()

func _generate_roam_point_target():
	var radius = enemt_zone.get_child(0).shape.radius
	
	var angle = randf() * TAU
	var r = sqrt(randf()) * radius
	
	var local_pos = Vector3(r * cos(angle), 0, r * sin(angle))
	var world_pos = enemt_zone.global_transform.origin + local_pos
	world_pos.y = global_transform.origin.y
	
	# print_debug("creating a new roam target", world_pos)
	
	agent.set_target_position(world_pos)
	roaming = true
	

func _face_to_vector3(point: Vector3) -> void:
	# get the relative position of the point from the agent
	var to_point = (point - global_position).normalized()
	
	# get the angle from the point
	var angle_y = atan2(to_point.x, to_point.z) + (PI / 2) # add a 90deg offset
	
	model.rotation.y = lerp_angle(model.rotation.y, angle_y, 0.5)

func _face_to_velocity() -> void:
	# a velocity point that points to the movement direction
	var linear_pos = linear_velocity.normalized()
	
	# get the angle from the point
	var angle_y = atan2(linear_pos.x, linear_pos.z) + (PI / 2) # add a 90deg offset
	
	model.rotation.y = lerp_angle(model.rotation.y, angle_y, 0.1)
