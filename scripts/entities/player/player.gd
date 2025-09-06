extends RigidBody3D

@onready var camera = $TwistPivot/PitchPivot/Camera3D
@onready var model = $Node3D

@onready var starter_weapon = $Node3D/StarterWeaponNode

# ty https://www.youtube.com/watch?v=sVsn9NqpVhg

# runs when node enters scene tree for the first time
func _ready() -> void:
	pass

# called every frame, delta is elapsed time since prev. frame
# delta allows variations between machines
func _process(delta: float) -> void:
	Globals.player_pos = self.position
	
	_render_equipment()
	_handle_equipment()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# var input = Input.get_action_strength("ui_up")
	# apply_central_force(input * Vector3.FORWARD * 1200.0 * delta)
	if Globals.player_physics_reset_event:
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		Globals.player_physics_reset_event = false
	
	if Globals.player_pushback_event != Vector3.ZERO:
		print_debug("recieved pushback event")
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

var attack_tween: Tween
func _handle_equipment() -> void:
	if Input.is_action_just_pressed("attack"):
		if Globals.slot_active == 1 and Globals.equipment[0] == "starter_weapon":
			if attack_tween and attack_tween.is_running():
				attack_tween.kill()
				starter_weapon.rotation.y = 0
			
			attack_tween = create_tween()
			attack_tween.tween_property(starter_weapon, "rotation:y", deg_to_rad(-95), 0.3).as_relative()
			
			await attack_tween.finished
			
			attack_tween = create_tween()
			attack_tween.tween_property(starter_weapon, "rotation:y", deg_to_rad(95), 0.4).as_relative()
			
