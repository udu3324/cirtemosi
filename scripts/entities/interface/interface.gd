extends Node3D

@onready var model = $Node3D
@onready var screen = $Node3D/Screen
@onready var screen_material: StandardMaterial3D = screen.material
@onready var screen_tex: NoiseTexture2D = screen.material.albedo_texture
@onready var audio_player = $Node3D/AudioStreamPlayer3D

var player_is_close: bool = false
var player_is_interacting: bool = false

var flashing: bool = false

var noise_period: float = 0.0

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
	
	if player_is_interacting:
		screen_material.albedo_color = Color(0.0, 0.039, 1.0, 1.0)
		screen_material.emission = Color(0.0, 0.039, 1.0, 1.0)
		screen_material.emission_enabled = true
		return
	
	# animation pass for far
	if player_is_close and !flashing:
		flashing = true
		
		await _flicker()
		if randf() < 0.5:
			await get_tree().create_timer(randf_range(0.1, 0.5)).timeout
			await _flicker()
		
		await get_tree().create_timer(randi_range(3, 9)).timeout
		
		flashing = false


func _flicker():
	screen_material.albedo_color = Color(0.0, 0.0, 0.0, 0.0)
	screen_material.emission = Color(0.0, 0.0, 0.0, 0.0)
	screen_material.emission_enabled = true
	
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

var tween

func _on_inner_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		player_is_interacting = true
		
		tween = create_tween()
		tween.parallel().tween_property(model, "rotation:x", -deg_to_rad(13.5), 1.3).as_relative()
		#rotate y for facing to player
		tween.parallel().tween_property(model, "rotation:z", -deg_to_rad(21.5), 1.3).as_relative()
		
		tween.parallel().tween_property(model, "position:y", 1, 1.5).as_relative()
		
		_face_to_vector3(Globals.player_pos)

func _on_inner_area_3d_body_exited(body: Node3D) -> void:
	if body.name.contains("Player"):
		player_is_interacting = false
		
		tween = create_tween()
		
		tween.parallel().tween_property(model, "global_position", model_position_rest, 1.0)

		tween.parallel().tween_property(model, "rotation:x", model_rotation_rest.x, 0.3)
		tween.parallel().tween_property(model, "rotation:z", model_rotation_rest.z, 0.3)
		




# from enemt.gd
func _face_to_vector3(point: Vector3) -> void:
	# get the relative position of the point from the agent
	var to_point = (point - model.global_position).normalized()
	
	# get the angle from the point
	var angle_y = atan2(to_point.x, to_point.z) + (PI / 4) # add a 90deg offset
	
	# model.rotation.y = lerp_angle(model.rotation.y, angle_y, 0.5)
	
	tween.parallel().tween_property(model, "rotation:y", angle_y, 1.5)
