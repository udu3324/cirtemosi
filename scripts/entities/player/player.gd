extends RigidBody3D

@onready var camera: Camera3D = $TwistPivot/PitchPivot/Camera3D
@onready var model = $Node3D

@onready var weapon_node = $Node3D/player_rev2/ArmLeft/LeftArm/WeaponNode
@onready var starter_weapon = $Node3D/player_rev2/ArmLeft/LeftArm/WeaponNode/starter_weapon2
@onready var bow = $Node3D/player_rev2/ArmLeft/LeftArm/WeaponNode/bow

@onready var string_1_bow = $Node3D/player_rev2/ArmLeft/LeftArm/WeaponNode/bow/one
@onready var string_2_bow = $Node3D/player_rev2/ArmLeft/LeftArm/WeaponNode/bow/two
@onready var string_3_bow = $Node3D/player_rev2/ArmLeft/LeftArm/WeaponNode/bow/three

@onready var left_leg = $Node3D/player_rev2/LegLeft
@onready var right_leg = $Node3D/player_rev2/LegRight
@onready var left_arm = $Node3D/player_rev2/ArmLeft
@onready var right_arm = $Node3D/player_rev2/ArmRight
@onready var torso = $Node3D/player_rev2/Torso2
@onready var head = $Node3D/player_rev2/Head2

@onready var left_leg_collision = $Node3D/player_rev2/LegLeft/CollisionShape3D
@onready var right_leg_collision = $Node3D/player_rev2/LegRight/CollisionShape3D
@onready var left_arm_collision = $Node3D/player_rev2/ArmLeft/CollisionShape3D
@onready var right_arm_collision = $Node3D/player_rev2/ArmRight/CollisionShape3D
@onready var torso_collision = $Node3D/player_rev2/Torso2/CollisionShape3D
@onready var head_collision = $Node3D/player_rev2/Head2/CollisionShape3D

@onready var audio_player = $Node3D/player_rev2/ArmLeft/LeftArm/WeaponNode/AudioStreamPlayer3D

var swoosh = preload("res://assets/audio/fx/player_attempt_hit.wav")
var hit_starter_weapon = preload("res://assets/audio/fx/starter_weapon_hit.wav")
var pull_out_bow = preload("res://assets/audio/fx/bow-pullout.wav")

var animating = false
var animate_reset = false
var animating_time = 0.0

var run_hp_ranout_once = false

# ty https://www.youtube.com/watch?v=sVsn9NqpVhg

# called every frame, delta is elapsed time since prev. frame
# delta allows variations between machines
func _process(delta: float) -> void:
	camera.size = Globals.camera_size
	
	Globals.player_pos = self.position
	
	if Globals.player_physics_processing:
		self.sleeping = false
		self.freeze = false
	else:
		self.sleeping = true
		self.freeze = true
	
	if Globals.health <= 0.0 and !run_hp_ranout_once:
		Globals.player_death_event = "ran_out_of_hp"
		
		run_hp_ranout_once = true
		
		_self_destruct()
	
	if Globals.health == 0.0:
		return
	
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
		_animate_moving(delta)
	else:
		_stop_moving_animation()
	
	_render_equipment()
	_handle_equipment()

func _self_destruct():
	self.sleeping = true
	self.freeze = true
	
	left_arm_collision.disabled = false
	left_arm.sleeping = false
	left_arm.freeze = false
	
	right_arm_collision.disabled = false
	right_arm.sleeping = false
	right_arm.freeze = false
	
	left_leg_collision.disabled = false
	left_leg.sleeping = false
	left_leg.freeze = false
	
	right_leg_collision.disabled = false
	right_leg.sleeping = false
	right_leg.freeze = false
	
	head_collision.disabled = false
	head.sleeping = false
	head.freeze = false
	
	torso_collision.disabled = false
	torso.sleeping = false
	torso.freeze = false
	
	Globals.player_can_move = false

func _animate_moving(delta):
	
	if !Globals.player_can_move:
		return
	
	animating = true
	
	var leg_speed = 20.0 if Input.is_action_pressed("sprint") else 10.0
	if Globals.player_is_stunned:
		leg_speed = 30.0 if Input.is_action_pressed("sprint") else 3.0
	
	# handle holding sprint when not having any stamina
	if Input.is_action_pressed("sprint") and Globals.stamina <= 1:
		leg_speed = 3.0 if Globals.player_is_stunned else 10.0
	
	animating_time += delta * leg_speed # speed
	
	left_leg.rotation.z = sin(animating_time) * 0.5
	right_leg.rotation.z = -sin(animating_time) * 0.5
	left_leg.rotation.z = -sin(animating_time) * 0.5
	right_leg.rotation.z = sin(animating_time) * 0.5
	
	if attacking:
		return
	
	left_arm.rotation.z = sin(animating_time) * 0.2
	right_arm.rotation.z = -sin(animating_time) * 0.2
	left_arm.rotation.z = -sin(animating_time) * 0.2
	right_arm.rotation.z = sin(animating_time) * 0.2

func _stop_moving_animation():
	if !animating:
		return
	
	if animate_reset:
		return
	
	animating = false
	animate_reset = true
	
	if attacking:
		return
	
	await get_tree().create_timer(0.8).timeout
	
	# todo
	var tween = create_tween()
	tween.parallel().tween_property(left_leg, "rotation:z", 0.0, 0.3)
	tween.parallel().tween_property(right_leg, "rotation:z", 0.0, 0.3)
	tween.parallel().tween_property(left_arm, "rotation:z", 0.0, 0.3)
	tween.parallel().tween_property(right_arm, "rotation:z", 0.0, 0.3)
	
	await tween.finished
	
	animate_reset = false

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# var input = Input.get_action_strength("ui_up")
	# apply_central_force(input * Vector3.FORWARD * 1200.0 * delta)
	if Globals.player_physics_reset_event:
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		Globals.player_physics_reset_event = false
	
	if Globals.player_pushback_event != Vector3.ZERO:
		#print_debug("recieved pushback event")
		
		if Globals.health <= 0:
			return
		
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
	
	if sprinting:
		if Globals.player_is_stunned:
			Globals.stamina = Globals.stamina - Globals.stamina_usage_stunned
		else:
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
	if Globals.player_is_stunned and !sprinting:
		force = 10 if sprinting else 7 # allow sprinting while stunned but normal speed
	
	if Globals.screen_relative_movement:
		apply_central_force(dir2 * force)
	else:
		apply_central_force(input.normalized() * force)
	
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
	
	# rotation based on input ----------
	var input := Vector3.ZERO
	
	input.x = Input.get_axis("ui_left", "ui_right")
	input.z = Input.get_axis("ui_up", "ui_down")
	
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

	#print_debug("angle is ", rad_to_deg(atan2(dir.x, dir.z)))
	if Globals.screen_relative_movement:
		model.rotation.y = lerp_angle(model.rotation.y, atan2(dir.x, dir.z) + (PI / 2), 0.1)
	else:
		model.rotation.y = lerp_angle(model.rotation.y, atan2(input.x, input.z) + (PI / 2), 0.1)
	

	# rotation based on velocity ------------
	
	# a velocity point that points to the movement direction
	#var linear_pos = linear_velocity.normalized()
	
	# get the angle from the point
	#var angle_y = atan2(linear_pos.x, linear_pos.z) + (PI / 2) # add a 90deg offset
	
	#model.rotation.y = lerp_angle(model.rotation.y, angle_y, 0.1)


func _render_equipment() -> void:
	starter_weapon.visible = false
	bow.visible = false
	
	if Globals.slot_active == 1 and Globals.equipment[0] == "starter_weapon":
		starter_weapon.visible = true
	elif Globals.slot_active == 2 and Globals.equipment[1] == "bow":
		bow.visible = true

var attacking = false
func _handle_equipment() -> void:
	if !Globals.player_can_move:
		return
	
	if !Input.is_action_just_pressed("attack"):
		return
	
	if attacking:
		return
	
	var held_item = Globals.equipment[Globals.slot_active - 1]
	
	if held_item == "starter_weapon":
		attacking = true
		
		Globals._play_fx(audio_player, swoosh, 0.0, randf_range(0.6, 1.0))
		
		# start animation
		var attack_tween = create_tween()
		attack_tween.parallel().tween_property(weapon_node, "rotation:y", deg_to_rad(85), 0.5)
		attack_tween.parallel().tween_property(left_arm, "rotation:y", deg_to_rad(25), 0.25)
		attack_tween.parallel().tween_property(left_arm, "rotation:z", deg_to_rad(105), 0.25)
		attack_tween.parallel().tween_property(left_arm, "position:x", 0.2, 0.5)
		attack_tween.parallel().tween_property(left_arm, "rotation:y", deg_to_rad(-75), 0.5)
		
		await attack_tween.finished
		
		# check if player hit an enemy
		
		# get all enemy nodes
		var enemies = _get_all_enemy_nodes()
		
		# for each enemy
		for enemy in enemies:
			var distance = position.distance_to(enemy.global_transform.origin)
			
			#print("player ", position, " | enemy ", enemy.global_transform.origin, " | distance ", distance)
			
			
			# check if distance is good
			if distance > Globals.item_info_dict[held_item]["range"]:
				continue
			
			# they already dead
			if enemy.get_parent().dead:
				continue
			
			var forward = -model.global_transform.basis.x.normalized()
			var to_enemy = ( enemy.global_transform.origin - model.global_transform.origin).normalized()
			
			var angle = rad_to_deg(forward.angle_to(to_enemy)) 
			
			# check if angle is in range
			if angle > Globals.item_info_dict[held_item]["cone"]:
				continue
			
			#print_debug("enemy was hit!")
			enemy.get_parent().health -= Globals.item_info_dict[held_item]["damage"]
			enemy.get_parent().attack_event = model.rotation.y - (PI / 2)
			
			Globals._play_fx(audio_player, hit_starter_weapon, 0.0, 0.8)
		
		# stop animation
		attack_tween = create_tween()
		attack_tween.parallel().tween_property(weapon_node, "rotation:y", 0, 0.25)
		attack_tween.parallel().tween_property(left_arm, "rotation:y", 0, 0.5)
		attack_tween.parallel().tween_property(left_arm, "rotation:z", 0, 0.5)
		attack_tween.parallel().tween_property(left_arm, "position:x", 0, 0.25)
		attack_tween.chain().tween_property(left_arm, "rotation:y", 0, 0.25)
		
		await attack_tween.finished
		
		attacking = false
	
	if held_item == "bow":
		attacking = true
		
		Globals._play_fx(audio_player, pull_out_bow, 0.0, 1.0)
		
		# start animation
		var attack_tween = create_tween()
		attack_tween.parallel().tween_property(weapon_node, "rotation:x", - deg_to_rad(5), 0.1)
		attack_tween.parallel().tween_property(weapon_node, "rotation:y", + deg_to_rad(23), 0.1)
		attack_tween.parallel().tween_property(weapon_node, "position:x", 0.3, 0.1)
		attack_tween.parallel().tween_property(weapon_node, "position:z", 0.3, 0.1)
		attack_tween.parallel().tween_property(left_arm, "rotation:y", deg_to_rad(25), 0.11)
		attack_tween.parallel().tween_property(left_arm, "rotation:z", deg_to_rad(105), 0.11)
		attack_tween.parallel().tween_property(left_arm, "position:x", 0.2, 0.1)
		attack_tween.chain().tween_property(left_arm, "rotation:y", deg_to_rad(-75), 0.1)
		
		await attack_tween.finished
		await get_tree().create_timer(0.03).timeout
		string_1_bow.visible = false
		string_2_bow.visible = true
		
		await get_tree().create_timer(0.03).timeout
		string_2_bow.visible = false
		string_3_bow.visible = true
		
		await get_tree().create_timer(0.04).timeout
		
		# spawn in projectile
		var local_offset = Vector3(-0.3, 0, 0)
		var spawn_pos = bow.global_transform.origin + bow.global_transform.basis * local_offset
		
		var projectile: RayCast3D = preload("res://scenes/items/bow_projectile.tscn").instantiate()
		projectile.speed = randf_range(10.0, 15.0)
		projectile.position = spawn_pos
		
		Globals.root_node_3d.add_child(projectile)
		
		projectile.rotation.y = model.rotation.y + (PI/2)
		
		# aim assist lol
		var enemies = _get_all_enemy_nodes()
		
		# for each enemy
		for enemy in enemies:
			var distance = position.distance_to(enemy.global_transform.origin)
			
			# check if too far
			if distance > Globals.item_info_dict[held_item]["range"]:
				continue
			
			# check if already dead
			if enemy.get_parent().dead:
				continue
			
			# check if angle is alright and is in the cone
			var forward = -model.global_transform.basis.x.normalized()
			var to_enemy = ( enemy.global_transform.origin - model.global_transform.origin).normalized()
			
			var angle = rad_to_deg(forward.angle_to(to_enemy)) 
			
			if angle > Globals.item_info_dict[held_item]["cone"]:
				continue
			
			#print("doing aim assist", enemy.get_parent().name)
			#DebugDraw3D.draw_line(bow.global_position, enemy.global_position, Color.AQUAMARINE)
			
			projectile.look_at(enemy.global_position, Vector3.UP)
			#print("doing aim assist2", projectile.rotation.y)
			break
		
		string_3_bow.visible = false
		string_1_bow.visible = true
		
		# stop animation
		attack_tween = create_tween()
		attack_tween.parallel().tween_property(weapon_node, "rotation:x", 0, 0.11)
		attack_tween.parallel().tween_property(weapon_node, "rotation:y", 0, 0.1)
		attack_tween.parallel().tween_property(weapon_node, "position:x", 0, 0.1)
		attack_tween.parallel().tween_property(weapon_node, "position:z", 0, 0.1)
		attack_tween.parallel().tween_property(left_arm, "rotation:y", 0, 0.1)
		attack_tween.parallel().tween_property(left_arm, "rotation:z", 0, 0.1)
		attack_tween.parallel().tween_property(left_arm, "position:x", 0, 0.11)
		attack_tween.chain().tween_property(left_arm, "rotation:y", 0, 0.11)

		await attack_tween.finished
		
		attacking = false

func _get_all_enemy_nodes() -> Array:
	var enemies = []
	
	for node in Globals._get_all_nodes(get_tree().root):
		#print_debug(node)
		if node.name == "EnemyCollisionMesh":
			#print_debug("found enemy", node)
			enemies.append(node)
	
	return enemies
