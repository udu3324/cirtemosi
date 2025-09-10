extends RigidBody3D

@onready var agent = $NavigationAgent3D
@onready var enemt_zone: Area3D = get_parent().get_child(0)
@onready var health_bar = $SubViewport/MarginContainer/HealthBar

@onready var model = $enemt
@onready var head = $enemt/Head2
@onready var right_hand = $enemt/Right2
@onready var left_hand = $enemt/Left2
@onready var particles = $enemt/GPUParticles3D

@onready var head_collision = $enemt/Head2/CollisionShape3D
@onready var right_hand_collision = $enemt/Right2/CollisionShape3D
@onready var left_hand_collision = $enemt/Left2/CollisionShape3D

@onready var main_body_collision = $CollisionShape3D2

@onready var audio_slash = $AudioStreamPlayer3D

var target_reached = true

var pause_logic = false

var roaming = false
var chasing = false

var health = 100.0
var attack_event = null
var dead = false

var stuck_time := 0.0

var tween: Tween = create_tween()
var left_rest_pos
var left_rest_rot
var right_rest_pos
var right_rest_rot

func _ready() -> void:
	_generate_roam_point_target()
	left_rest_pos = left_hand.position
	left_rest_rot = left_hand.rotation
	
	right_rest_pos = right_hand.position
	right_rest_rot = right_hand.rotation

func _process(delta: float) -> void:
	health_bar.value = health
	
	if attack_event != null:
		
		print_debug("recieved attack event")
		#var linear_pos = linear_velocity.normalized()
	
		# get the angle from the point \ also assume angle is facing player cause yeah
		#var angle_y = atan2(linear_pos.x, linear_pos.z) - (PI / 2)
		
		var direction = Vector3(sin(attack_event), 0, cos(attack_event))
		
		apply_central_force(direction * randi_range(100, 400))
		
		attack_event = null
		
	
	if health == 100.0 or dead:
		health_bar.visible = false
	else:
		health_bar.visible = true
	
	if health == 0.0 and !dead:
		self.sleeping = true
		self.freeze = true
		
		dead = true
		particles.emitting = false
		
		#print_debug("enemy is dead")
		
		left_hand_collision.disabled = false
		left_hand.sleeping = false
		left_hand.freeze = false
		
		right_hand_collision.disabled = false
		right_hand.sleeping = false
		right_hand.freeze = false
		
		main_body_collision.disabled = true
		head_collision.disabled = false
		head.sleeping = false
		head.freeze = false
		
		return
	

func _physics_process(delta: float) -> void:
	if agent.is_navigation_finished() and !dead:
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
	
	#print("chasing ", chasing, "|pause_logic ", pause_logic, "|is_navigation_finished ", agent.is_navigation_finished())
	
	# dont need to move if its finised reaching target
	if agent.is_navigation_finished() and !chasing:
		return
	
	# attempting attack waits / etc
	if pause_logic:
		return
	
	# rotate based on if chasing or roaming
	if chasing:
		_face_to_vector3(Globals.player_pos)
	
	# agent is chasing and is too close to player!
	if global_transform.origin.distance_to(Globals.player_pos) < 1.3 and chasing:
		_attempt_attack()
		return
	
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
	
	# model.rotation.y = lerp_angle(model.rotation.y, angle_y, 0.5)
	var tween = create_tween()
	tween.tween_property(model, "rotation:y", angle_y, 0.1)

func _face_to_velocity() -> void:
	# a velocity point that points to the movement direction
	var linear_pos = linear_velocity.normalized()
	
	# get the angle from the point
	var angle_y = atan2(linear_pos.x, linear_pos.z) + (PI / 2) # add a 90deg offset
	
	# model.rotation.y = lerp_angle(model.rotation.y, angle_y, 0.1)
	var tween = create_tween()
	tween.tween_property(model, "rotation:y", angle_y, 0.1)

func _attempt_attack():
	pause_logic = true
	
	# _face_to_vector3(Globals.player_pos)
	
	# wait still for a bit to give player a change (also rng)
	await get_tree().create_timer(randf_range(0.03, 0.3)).timeout
	
	if tween.is_running():
		tween.stop()
	
	# animate
	# right_hand.position.x -= 0.3
	# right_hand.rotation.y = lerp_angle(right_hand.rotation.y, right_hand.rotation.y - deg_to_rad(80), 0.1)
	
	audio_slash.pitch_scale = randf_range(0.7, 0.9)
	audio_slash.play()
	
	tween = create_tween()
	tween.tween_property(right_hand, "position:x", - 0.53, 0.07).as_relative()
	tween.tween_property(right_hand, "position:z", 0.2, 0.07).as_relative()
	tween.tween_property(right_hand, "rotation:y", deg_to_rad(80), 0.03).as_relative()
	tween.tween_property(right_hand, "rotation:z", deg_to_rad(25), 0.03).as_relative()
	await get_tree().create_timer(0.03).timeout
	tween = create_tween()
	tween.tween_property(left_hand, "position:x", - 0.55, 0.09).as_relative()
	tween.tween_property(left_hand, "position:z", - 0.2, 0.09).as_relative()
	tween.tween_property(left_hand, "rotation:y", - deg_to_rad(80), 0.03).as_relative()
	tween.tween_property(left_hand, "rotation:z", - deg_to_rad(45), 0.03).as_relative()
	#await tween.finished
	await get_tree().create_timer(randf_range(0, 0.1)).timeout
	
	# this wait gives time for player to dodge
	# await get_tree().create_timer(0.17).timeout
	
	# attempt attack
	if global_transform.origin.distance_to(Globals.player_pos) < 1.4:
		_face_to_vector3(Globals.player_pos)
		
		#Globals.player_can_move = false
		Globals.player_is_stunned = true
		
		# this math was pretty much trial and error to get it working, i literally cant visualize this in my head
		var force_push = Vector3(-cos(model.rotation.y), 0, sin(model.rotation.y)).normalized()
		Globals.player_pushback_event = force_push * randi_range(2, 5)
		Globals.player_physics_reset_event = true
		
		Globals.health -= 5
		
		await _timeout_player()
	
	# in case if scene has been unloaded
	if get_tree() == null:
		return
	
	# wait still for recovery
	await get_tree().create_timer(randf_range(0.5, 1.5)).timeout
	
	# animate back
	# right_hand.position.x += 0.3
	# right_hand.rotation.y = lerp_angle(right_hand.rotation.y, right_hand.rotation.y + deg_to_rad(80), 0.1)
	tween = create_tween()
	tween.tween_property(right_hand, "rotation", right_rest_rot, 0.13)
	tween.tween_property(right_hand, "position", right_rest_pos, 0.17)
	
	# in case if scene has been unloaded or game was paused
	if get_tree() == null:
		return
	
	await get_tree().create_timer(0.03).timeout
	tween = create_tween()
	tween.tween_property(left_hand, "rotation", left_rest_rot, 0.13)
	tween.tween_property(left_hand, "position", left_rest_pos, 0.17)
	await tween.finished
	
	# wait a little more to recover + animate to the next one smoothly
	# await get_tree().create_timer(0.15).timeout
	
	# continue
	pause_logic = false

func _timeout_player():
	await get_tree().create_timer(2).timeout
	#Globals.player_can_move = true
	Globals.player_is_stunned = false
