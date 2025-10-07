extends RigidBody3D

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var zert_zone: Area3D = get_parent().get_child(0)
@onready var health_bar: ProgressBar = $SubViewport/MarginContainer/HealthBar

@onready var model: Node3D = $zert
@onready var head: RigidBody3D = $zert/Head2
@onready var right_hand: RigidBody3D = $zert/Right2
@onready var left_hand: RigidBody3D = $zert/Left2
@onready var floating_ball: MeshInstance3D = $zert/Head2/FloatingBall
@onready var floating_ball_material: StandardMaterial3D = floating_ball.get_active_material(0)

@onready var ring_collision: CollisionShape3D = $zert/Head2/CollisionShape3D
@onready var head_collision: CollisionShape3D = $zert/Head2/CollisionShape3D2
@onready var right_hand_collision: CollisionShape3D = $zert/Right2/CollisionShape3D
@onready var left_hand_collision: CollisionShape3D = $zert/Left2/CollisionShape3D

@onready var main_body_collision: CollisionShape3D = $CollisionShape3D

@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var array_death_log: int = 0
var ignore_player: bool = false
var despawns: bool = true
var drops_relic_3: bool = false
var drops_shards: bool = true
var rng_shard_drops: bool = true
var rand_shard_range: int = 20

var target_reached: bool = true

var pause_logic: bool = false

var roaming = false
var circling = false

var health = 150.0
var attack_event = null
var dead = false

var stuck_time: float = 0.0
var attack_period: float = 0.0
var attack_next_wait: float = 0.0
var roaming_period: float = 0.0
var roaming_next_wait: float = 0.0

var tween: Tween = create_tween()

var left_rest_pos
var left_rest_rot
var right_rest_pos
var right_rest_rot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	roaming = true
	
	attack_next_wait = randf_range(3.0, 5.0)
	roaming_next_wait = randf_range(5.0, 7.0)
	
	left_rest_pos = left_hand.position
	left_rest_rot = left_hand.rotation
	right_rest_pos = right_hand.position
	right_rest_rot = right_hand.rotation


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	health_bar.value = health
	
	if attack_event != null:
		pass #todo
	
	if health == 150.0 or dead:
		health_bar.visible = false
	else:
		health_bar.visible = true
	
	if health <= 0.0 and !dead:
		dead = true
		
		# todo death event and effect

func _physics_process(delta: float) -> void:
	
	if circling:
		attack_period += delta
		floating_ball_material.emission_energy_multiplier = remap(attack_period, 0, attack_next_wait, 0.3, 1.5)
		
		agent.set_target_position(Globals.player_pos)
	
	if attack_period >= attack_next_wait:
		attack_period = 0.0
		attack_next_wait = randf_range(3.0, 5.0)
		#todo attack
		print_debug("attempting attack!")
		pass
	
	if roaming:
		roaming_period += delta
	
	if roaming_period >= roaming_next_wait and agent.is_navigation_finished():
		roaming_period = 0.0
		roaming_next_wait = randf_range(4.0, 7.0)
		
		_generate_roam_point_target()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	
	# check if player is inside of attack cone + in distance
	#print_debug("quicvk maffs", (rad_to_deg(angle_y) - rad_to_deg(model.rotation.y)))
	var to_point = (Globals.player_pos - global_position).normalized()
	var angle_y = atan2(to_point.x, to_point.z) + (PI / 2)
	var cone = rad_to_deg(angle_y) - rad_to_deg(model.rotation.y)
	if global_transform.origin.distance_to(Globals.player_pos) < 10 and Globals.player_pos != Vector3(0, 0, 0) and !Globals.resetVisible and !ignore_player:
		if cone > -30 and cone < 30:
			roaming = false
			circling = true
	
	# too close and not in cone
	if global_transform.origin.distance_to(Globals.player_pos) < 1.5 and Globals.player_pos != Vector3(0, 0, 0) and !Globals.resetVisible and !ignore_player:
		roaming = false
		circling = true
	
	# too far and fell out of cone region
	if global_transform.origin.distance_to(Globals.player_pos) > 12 and circling:
		circling = false
		floating_ball_material.emission_energy_multiplier = 0.3
		
		_generate_roam_point_target()
	
	# dont need to move if went to target position
	if agent.is_navigation_finished() and !circling:
		return
	
	# use rotation based on player if circling
	if circling:
		_face_to_vector3(Globals.player_pos)
	
	# dont need to go too close while circling
	if circling and global_transform.origin.distance_to(Globals.player_pos) <= 5:
		
		return
	
	# attempt attacks waits / etc?
	
	
	
	# stop circling
	
	
	
	
	
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
	
	var force = 16 if circling else 10
	apply_central_force(dir2 * force)
	
	# apply an extra y axis force depending on the slope angle
	var slope_angle = acos(slope_normal.dot(Vector3.UP))
	if slope_angle > 0.0 and slope_angle < deg_to_rad(60):
		var boost = (slope_angle / deg_to_rad(45)) * 7
		apply_central_force(Vector3.UP * boost)
	
	if roaming:
		_face_to_velocity()


func _face_to_vector3(point: Vector3) -> void:
	# get the relative position of the point from the agent
	var to_point = (point - global_position).normalized()
	
	# get the angle from the point
	var angle_y = atan2(to_point.x, to_point.z) + (PI / 2) # add a 90deg offset
	
	# model.rotation.y = lerp_angle(model.rotation.y, angle_y, 0.5)
	var rotate_tween = create_tween()
	rotate_tween.tween_property(model, "rotation:y", angle_y, 0.1)

func _face_to_velocity() -> void:
	# a velocity point that points to the movement direction
	var linear_pos = linear_velocity.normalized()
	
	# get the angle from the point
	var angle_y = atan2(linear_pos.x, linear_pos.z) + (PI / 2) # add a 90deg offset
	
	# model.rotation.y = lerp_angle(model.rotation.y, angle_y, 0.1)
	var rotate_tween = create_tween()
	rotate_tween.tween_property(model, "rotation:y", angle_y, 0.1)

func _generate_roam_point_target():
	var radius = zert_zone.get_child(0).shape.radius
	
	var angle = randf() * TAU
	var r = sqrt(randf()) * radius
	
	var local_pos = Vector3(r * cos(angle), 0, r * sin(angle))
	var world_pos = zert_zone.global_transform.origin + local_pos
	world_pos.y = global_transform.origin.y
	
	# print_debug("creating a new roam target", world_pos)
	
	agent.set_target_position(world_pos)
	roaming = true
	
