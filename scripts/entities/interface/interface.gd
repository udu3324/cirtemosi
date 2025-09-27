extends Node3D

@onready var model = $Node3D
@onready var screen = $Node3D/Screen
@onready var screen_material: StandardMaterial3D = screen.material
@onready var screen_tex: NoiseTexture2D = screen.material.albedo_texture
@onready var audio_player = $Node3D/AudioStreamPlayer3D

@onready var text: Node3D = $Node3D/Text
@onready var underscore: Node3D = $Node3D/Text/Underscore

@onready var panel = $SubViewport/InterfaceDialogue
@onready var intro = $SubViewport/InterfaceDialogue/MarginContainer2
@onready var dialogue = $SubViewport/InterfaceDialogue/MarginContainer

var terminal_color: Color = Color(0.021, 0.258, 0.021, 1.0)

var player_is_close: bool = false
var player_is_interacting: bool = false

var flashing: bool = false

var noise_period: float = 0.0
var turn_period: float = 0.0
var underscore_period: float = 0.0

var model_rotation_rest
var model_position_rest

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	model_position_rest = model.global_position
	model_rotation_rest = model.rotation


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	 
	# change seed of noise
	noise_period += delta
	if noise_period > 0.1:
		screen_tex.noise.seed += 1
		noise_period = 0
	
	
	if text.visible:
		panel.visible = true
		_handle_input()
	else:
		panel.visible = false
	
	
	
	if player_is_interacting:
		underscore_period += delta
		if underscore_period > 1.0:
			underscore.visible = !underscore.visible
			
			underscore_period = 0
		
		turn_period += delta
		if turn_period > 6.0:
			tween = create_tween()
			_face_to_vector3(Globals.player_pos)
			
			turn_period = 0
		
		if !flashing:
			flashing = true
			
			await _flicker()
			if randf() < 0.5:
				await get_tree().create_timer(randf_range(1.0, 1.5)).timeout
				await _flicker()
			
			await get_tree().create_timer(randi_range(6, 9)).timeout
			
			flashing = false
		
		if !text.visible:
			await get_tree().create_timer(2.0).timeout
			
			# stops user from going back and forth glitching the text
			if !player_is_interacting:
				return
			
			text.visible = true
		
		return
	else:
		text.visible = false
	
	# animation pass for far
	if player_is_close and !flashing:
		flashing = true
		
		await _flicker()
		if randf() < 0.5:
			await get_tree().create_timer(randf_range(0.1, 0.5)).timeout
			await _flicker()
		
		await get_tree().create_timer(randi_range(3, 9)).timeout
		
		flashing = false

func _handle_input():
	if Input.is_action_just_pressed("attack"):
		if intro.visible:
			Globals.player_can_move = false
			intro.visible = false
			dialogue.visible = true
		else:
			Globals.player_can_move = true
			intro.visible = true
			dialogue.visible = false

func _flicker():
	screen_material.emission_energy_multiplier = randf_range(0.3, 0.8)
	
	screen_material.albedo_color = Color(0.0, 0.0, 0.0, 0.0)
	screen_material.emission = Color(0.0, 0.0, 0.0, 0.0)
	screen_material.emission_enabled = true
	
	if player_is_interacting:
		await get_tree().create_timer(0.1).timeout
		
		screen_material.albedo_color = terminal_color
		screen_material.emission = terminal_color
	else:
		await get_tree().create_timer(randf_range(0.1, 0.5)).timeout
		
		screen_material.albedo_color = Color(0.0, 0.0, 0.0, 1.0)
		screen_material.emission = Color(0.0, 0.0, 0.0, 1.0)
		screen_material.emission_enabled = false
		

func _on_outer_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		player_is_close = true

func _on_outer_area_3d_body_exited(body: Node3D) -> void:
	if body.name.contains("Player"):
		player_is_close = false

var tween = create_tween()

func _on_inner_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		player_is_interacting = true
		
		if tween.is_running():
			tween.kill()
		
		tween = create_tween()
		tween.parallel().tween_property(model, "rotation:x", -deg_to_rad(13.5), 1.3).as_relative()
		#rotate y for facing to player
		tween.parallel().tween_property(model, "rotation:z", -deg_to_rad(21.5), 1.3).as_relative()
		
		tween.parallel().tween_property(model, "position:y", 1, 1.5).as_relative()
		
		_face_to_vector3(Globals.player_pos)
		
		screen_material.albedo_color = terminal_color
		screen_material.emission = terminal_color
		screen_material.emission_enabled = true
		screen_material.emission_energy_multiplier = 0.4
		
		screen.material.emission_texture = null
		screen.material.albedo_texture = null

func _on_inner_area_3d_body_exited(body: Node3D) -> void:
	if body.name.contains("Player"):
		player_is_interacting = false
		
		if tween.is_running():
			tween.kill()
		
		tween = create_tween()
		
		tween.parallel().tween_property(model, "global_position", model_position_rest, 0.3)

		tween.parallel().tween_property(model, "rotation:x", model_rotation_rest.x, 0.3)
		tween.parallel().tween_property(model, "rotation:z", model_rotation_rest.z, 0.3)
		
		screen_material.albedo_color = Color(0.0, 0.0, 0.0, 1.0)
		screen_material.emission = Color(0.0, 0.0, 0.0, 1.0)
		screen_material.emission_enabled = false
		flashing = false
		
		screen.material.emission_texture = preload("res://assets/gdtex/screen_noise.tres")
		screen.material.albedo_texture = preload("res://assets/gdtex/screen_noise.tres")
		
		text.visible = false



# from enemt.gd
func _face_to_vector3(point: Vector3) -> void:
	# get the relative position of the point from the agent
	var to_point = (point - model.global_position).normalized()
	
	# get the angle from the point
	var angle_y = atan2(to_point.x, to_point.z) + (PI / 4) # add a 90deg offset
	
	# model.rotation.y = lerp_angle(model.rotation.y, angle_y, 0.5)
	
	tween.parallel().tween_property(model, "rotation:y", angle_y, 1.5)
