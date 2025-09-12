extends RigidBody3D

@onready var camera = $TwistPivot/PitchPivot/Camera3D
@onready var model = $Node3D

@onready var starter_weapon = $Node3D/player_rev2/ArmLeft/LeftArm/StarterWeaponNode
@onready var left_leg = $Node3D/player_rev2/LegLeft
@onready var right_leg = $Node3D/player_rev2/LegRight
@onready var left_arm = $Node3D/player_rev2/ArmLeft
@onready var right_arm = $Node3D/player_rev2/ArmRight

var animating_legs = false
var animate_leg_reset = false
var animating_leg_time = 0.0

# ty https://www.youtube.com/watch?v=sVsn9NqpVhg

# runs when node enters scene tree for the first time
func _ready() -> void:
	pass

# called every frame, delta is elapsed time since prev. frame
# delta allows variations between machines
func _process(delta: float) -> void:
	Globals.player_pos = self.position
	
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
		_animate_legs(delta)
	else:
		_stop_leg_animation()
	
	_render_equipment()
	_handle_equipment()

func _animate_legs(delta):
	animating_legs = true
	
	var leg_speed = 20.0 if Input.is_action_pressed("sprint") else 10.0
	
	animating_leg_time += delta * leg_speed # speed
	
	left_leg.rotation.z = sin(animating_leg_time) * 0.5
	right_leg.rotation.z = -sin(animating_leg_time) * 0.5
	left_leg.rotation.z = -sin(animating_leg_time) * 0.5
	right_leg.rotation.z = sin(animating_leg_time) * 0.5

func _stop_leg_animation():
	if !animating_legs:
		return
	
	if animate_leg_reset:
		return
	
	animating_legs = false
	animate_leg_reset = true
	
	await get_tree().create_timer(0.8).timeout
	
	# todo
	var tween = create_tween()
	tween.tween_property(left_leg, "rotation:z", 0.0, 0.3)
	tween.tween_property(right_leg, "rotation:z", 0.0, 0.3)
	
	await tween.finished
	
	animate_leg_reset = false

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# var input = Input.get_action_strength("ui_up")
	# apply_central_force(input * Vector3.FORWARD * 1200.0 * delta)
	if Globals.player_physics_reset_event:
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		Globals.player_physics_reset_event = false
	
	if Globals.player_pushback_event != Vector3.ZERO:
		#print_debug("recieved pushback event")
		apply_central_force(Globals.player_pushback_event * 100)
		
		Globals.player_pushback_event = Vector3.ZERO
	
	var input := Vector3.ZERO
	
	input.x = Input.get_axis("ui_left", "ui_right")
	input.z = Input.get_axis("ui_up", "ui_down")
	
	var sprinting = Input.is_action_pressed("sprint")
	if Globals.stamina < 0:
		sprinting = false
	
	if input == Vector3.ZERO or !Globals.player_can_move:
		return
	
	if sprinting and !Globals.player_is_stunned:
		Globals.stamina = Globals.stamina - Globals.stamina_usage
	
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
	var force = 20 if sprinting else 13
	force = 7 if Globals.player_is_stunned else force
	apply_central_force(dir2 * force)
	
	# apply an extra y axis force depending on the slope angle
	var slope_angle = acos(slope_normal.dot(Vector3.UP))
	if slope_angle > 0.0 and slope_angle < deg_to_rad(60):
		# multi * 10 for running | 5 for regular
		var force_slope = 10 if sprinting else 5
		force_slope = 3 if Globals.player_is_stunned else force_slope
		var boost = (slope_angle / deg_to_rad(45)) * force_slope
		apply_central_force(Vector3.UP * boost)
		# print_debug("adding upward force to assist slope movement", boost)
		# print_debug("angle is", slope_angle)
	
	# apply_central_force(Vector3(0, 5, 0))
	_face_to_velocity()

func _face_to_velocity() -> void:
	# a velocity point that points to the movement direction
	var linear_pos = linear_velocity.normalized()
	
	# get the angle from the point
	var angle_y = atan2(linear_pos.x, linear_pos.z) + (PI / 2) # add a 90deg offset
	
	model.rotation.y = lerp_angle(model.rotation.y, angle_y, 0.1)
	# var tween = create_tween()
	# tween.tween_property(model, "rotation:y", angle_y, 0.1)

func _render_equipment() -> void:
	if Globals.slot_active == 1 and Globals.equipment[0] == "starter_weapon":
		starter_weapon.visible = true
	else:
		starter_weapon.visible = false

var attacking = false
func _handle_equipment() -> void:
	if Input.is_action_just_pressed("attack"):
		if Globals.slot_active == 1 and Globals.equipment[0] == "starter_weapon":
			if attacking:
				return
			
			attacking = true
			
			# start animation
			var attack_tween = create_tween()
			attack_tween.tween_property(left_arm, "rotation:z", deg_to_rad(75), 0.2)
			attack_tween.tween_property(left_arm, "position:x", 0.1, 0.1)
			attack_tween.tween_property(left_arm, "rotation:x", deg_to_rad(85), 0.1)
			attack_tween.tween_property(left_arm, "rotation:y", deg_to_rad(-35), 0.3)
			#attack_tween.tween_property(starter_weapon, "position:x", -0.2, 0.1).as_relative()
			#attack_tween.tween_property(starter_weapon, "rotation:y", deg_to_rad(-95), 0.3).as_relative()
			
			await attack_tween.finished
			
			# check if player hit an enemy
			
			# get all enemy nodes
			var enemies = []
			for node in _get_all_nodes(get_tree().root):
				#print_debug(node)
				if node.name == "EnemyCollisionMesh":
					#print_debug("found enemy", node)
					enemies.append(node)
			
			# for each enemy
			for enemy in enemies:
				var distance = position.distance_to(enemy.global_transform.origin)
				
				#print("player ", position, " | enemy ", enemy.global_transform.origin, " | distance ", distance)
				
				# check if distance is good
				if distance > 1.5:
					continue
				
				var forward = -model.global_transform.basis.x.normalized()
				var to_enemy = ( enemy.global_transform.origin - model.global_transform.origin).normalized()
				
				var angle = rad_to_deg(forward.angle_to(to_enemy))
				
				# check if angle is in range
				if angle > 60: # currently very generous right now
					continue
				
				#print_debug("enemy was hit!")
				enemy.get_parent().health -= 10
				enemy.get_parent().attack_event = model.rotation.y - (PI / 2)
			
			# stop animation
			attack_tween = create_tween()
			#attack_tween.tween_property(starter_weapon, "rotation:y", deg_to_rad(95), 0.4).as_relative()
			#attack_tween.tween_property(starter_weapon, "position:x", 0.2, 0.1).as_relative()
			attack_tween.tween_property(left_arm, "rotation:y", 0, 0.2)
			attack_tween.tween_property(left_arm, "rotation:x", 0, 0.2)
			attack_tween.tween_property(left_arm, "position:x", 0, 0.2)
			attack_tween.tween_property(left_arm, "rotation:z", 0, 0.2)
			await attack_tween.finished
			
			attacking = false

func _get_all_nodes(node) -> Array:
	var nodes = []
	
	for child in node.get_children():
		nodes.append(child)
		nodes += _get_all_nodes(child)
	
	return nodes
