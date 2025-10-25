extends Node3D


@export_range (10, 500) var healing_size: int = 30
@export_range (1, 7) var relic_num: int = 1
@export var relic_outline: Color = Color(0.518, 0.075, 0.122)

@export var relic_hidden: CompressedTexture2D = preload("res://assets/relics/relic_1_hidden_icon.png")
@export var relic_shown: CompressedTexture2D = preload("res://assets/relics/relic_1_icon.png")

@onready var model = $Node3D
@onready var screen = $Node3D/Screen
@onready var screen_material: StandardMaterial3D = screen.material
@onready var screen_tex: NoiseTexture2D = screen.material.albedo_texture
@onready var audio_player = $Node3D/AudioStreamPlayer3D

@onready var text: Node3D = $Node3D/Text
@onready var underscore: Node3D = $Node3D/Text/Underscore

@onready var panel = $SubViewport/InterfaceDialogue
@onready var intro: MarginContainer = $SubViewport/InterfaceDialogue/MarginContainer2
@onready var dialogue: MarginContainer = $SubViewport/InterfaceDialogue/MarginContainer
@onready var dialogue_list: VBoxContainer = $SubViewport/InterfaceDialogue/MarginContainer/HBoxContainer/List

@onready var relic: TextureRect = $SubViewport/InterfaceDialogue/MarginContainer/HBoxContainer/List/Relic/TextureRect

@onready var dialogue_response: Label = $SubViewport2/MarginContainer/Label
@onready var dialogue_encrypted_response: Label = $SubViewport3/MarginContainer/Label

@onready var boot = preload("res://assets/audio/fx/interface_boot.wav")
@onready var shutdown = preload("res://assets/audio/fx/interface_shutdown.wav")
@onready var static_sound = preload("res://assets/audio/fx/interface_static.wav")
@onready var select = preload("res://assets/audio/fx/interface_select.wav")
@onready var type = preload("res://assets/audio/fx/interface_untranslated.wav")

var terminal_color: Color = Color(0.021, 0.258, 0.021, 1.0)

var player_is_close: bool = false
var player_is_interacting: bool = false

var flashing: bool = false

var noise_period: float = 0.0
var turn_period: float = 0.0
var underscore_period: float = 0.0

var model_rotation_rest
var model_position_rest

var ignore_input: bool = false

@onready var menus = {
	"main": {
		"container": $SubViewport/InterfaceDialogue/MarginContainer/HBoxContainer/List,
		"cursor": $SubViewport/InterfaceDialogue/MarginContainer/HBoxContainer/Cursor/Label,
		"dialogue_option": null,
		"index_max": 2,
		"index": 0
	},
	"weapon": {
		"container": $SubViewport/InterfaceDialogue/MarginContainer/HBoxContainer/List/SubWeapon,
		"cursor": $SubViewport/InterfaceDialogue/MarginContainer/HBoxContainer/List/SubWeapon/List/Cursor/Cursor,
		"dialogue_option": $SubViewport/InterfaceDialogue/MarginContainer/HBoxContainer/List/Weapon,
		"index_max": 1,
		"index": 0
	},
	"health": {
		"container": $SubViewport/InterfaceDialogue/MarginContainer/HBoxContainer/List/SubHealth,
		"cursor": $SubViewport/InterfaceDialogue/MarginContainer/HBoxContainer/List/SubHealth/List/Cursor/Cursor,
		"dialogue_option": $SubViewport/InterfaceDialogue/MarginContainer/HBoxContainer/List/Health,
		"index_max": 1,
		"index": 0
	},
	"relic": {
		"container": $SubViewport/InterfaceDialogue/MarginContainer/HBoxContainer/List/SubRelic,
		"cursor": $SubViewport/InterfaceDialogue/MarginContainer/HBoxContainer/List/SubRelic/List/Cursor/Cursor,
		"dialogue_option": $SubViewport/InterfaceDialogue/MarginContainer/HBoxContainer/List/Relic,
		"index_max": 0,
		"index": 0
	},
}

var active_menu := "main"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	model_rotation_rest = model.rotation
	
	relic.texture = relic_hidden
	relic.material.set_shader_parameter("line_color", relic_outline)
	
	# reset dialogue visiblity in case if i forgot to do it in editor :cry:
	intro.visible = true
	dialogue.visible = false
	
	menus["weapon"]["container"].visible = false
	menus["health"]["container"].visible = false
	menus["relic"]["container"].visible = false
	
	_set_active_menu("main")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# show the relic if they have it
	if relic.texture == relic_hidden and Globals.relics[relic_num - 1]:
		relic.texture = relic_shown
	
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
	if ignore_input:
		return
	
	if Input.is_action_just_pressed("attack"):
		if intro.visible:
			Globals.player_can_move = false
			intro.visible = false
			dialogue.visible = true
			
			# reset opacities
			menus["weapon"]["dialogue_option"].modulate.a = 1.0
			menus["health"]["dialogue_option"].modulate.a = 1.0
			menus["relic"]["dialogue_option"].modulate.a = 1.0
		else:
			
			intro.visible = true
			dialogue.visible = false
			
			# reset cursors
			for key in menus.keys():
				menus[key]["index"] = 0
				menus[key]["cursor"].text = ">"
			
			dialogue_response.text = ""
			dialogue_encrypted_response.text = ""
			
			_set_active_menu("main")
			
			# stop input from turning into an actual interaction
			await get_tree().create_timer(0.1).timeout
			Globals.player_can_move = true
	
	# dont let controls continue to interface if intro still visible
	if intro.visible:
		return
	
	# remove the main cursor if in submenu
	if active_menu != "main" and menus["main"]["cursor"].text != "":
		menus["main"]["cursor"].text = ""
	
	if Input.is_action_just_pressed("ui_up"):
		_move_cursor(-1)
	
	if Input.is_action_just_pressed("ui_down"):
		_move_cursor(1)
	
	# submenu switching
	if Input.is_action_just_pressed("ui_right"):
		if active_menu == "main":
			match menus["main"]["index"]:
				0: _set_active_menu("weapon")
				1: _set_active_menu("health")
				2: _set_active_menu("relic")
		else:
			Globals._play_fx(audio_player, select, 0.0, 1.0)
			_handle_terminal_final_enter()
	
	if Input.is_action_just_pressed("ui_left") and active_menu != "main":
		_set_active_menu("main")
		
		for key in menus.keys():
			if menus[key]["dialogue_option"] != null:
				menus[key]["dialogue_option"].modulate.a = 1.0
		
		# put back the main cursor
		menus["main"]["cursor"].text = "\n".repeat(menus["main"]["index"]) + ">"

func _set_active_menu(menu_name: String):
	# scan key with container name to set that one visible
	for key in menus.keys():
		menus[key]["container"].visible = (key == menu_name)
		
		# and set the opacity for the rest of the options in main menu
		if menus[key]["dialogue_option"] != null:
			menus[key]["dialogue_option"].modulate.a = 1.0 if (key == menu_name) else 0.3
	
	# dialogue list is always visible, dont hide it
	dialogue_list.visible = true
	
	active_menu = menu_name

func _move_cursor(direction: int):
	menus[active_menu]["index"] = clamp(menus[active_menu]["index"] + direction, 0, menus[active_menu]["index_max"])
	menus[active_menu]["cursor"].text = "\n".repeat(menus[active_menu]["index"]) + ">"

func _handle_terminal_final_enter():
	#print_debug("caught action of ", menus[active_menu]["index"], active_menu)
	ignore_input = true
	
	for key in menus.keys():
		if menus[key]["dialogue_option"] != null:
			menus[key]["dialogue_option"].modulate.a = 0.3
	
	var index = menus[active_menu]["index"]
	
	match active_menu:
		"weapon":
			match index:
				0:
					if Globals.equipment[Globals.slot_active - 1] == "":
						await _animate_text_typing("you dont have an\nactive weapon", 0.07)
					else:
						await _animate_text_typing("this is a [" + Globals.equipment[Globals.slot_active - 1] + "],\nit deals damage", 0.07)
				1:
					if Globals.shards >= 30:
						await _animate_text_typing("your 30 shards are\nbeing transformed now", 0.12)
						Globals.shards -= 30
						Globals.item_info_dict[Globals.equipment[Globals.slot_active - 1]]["damage"] += 5
						await _animate_text_typing("your [" + Globals.equipment[Globals.slot_active - 1] + "] now deals\nmore damage than before", 0.3)
					else:
						await _animate_text_typing("do you even\nhave the shards", 0.23)
		"health":
			match index:
				0:
					await _animate_text_typing("this is your health.\nyou have [" + str(Globals.health) + "] left", 0.07)
				1:
					if Globals.health >= Globals.health_max:
						await _animate_text_typing("you dont need this.", 0.2)
					elif Globals.shards >= 5:
						await _animate_text_typing("your 5 shards are\nbeing transformed now", 0.12)
						
						Globals.shards -= 5
						if (Globals.health + healing_size) > Globals.health_max:
							Globals.health = Globals.health_max
						else:
							Globals.health += healing_size
						
						await _animate_text_typing("your character is now\nloaded with new health", 0.16)
					else:
						await _animate_text_typing("do you even\nhave the shards", 0.23)
		"relic":
			match index:
				0:
					if Globals.relics[relic_num - 1]: # has the relic
						# todo all relic messages
						match relic_num:
							1:
								await _animate_text_typing("yet to be the last.\nkey for the first.", 0.15)
							3:
								await _animate_text_typing("the energy held can power cities for centuries", 0.15)
					else:
						match relic_num:
							1:
								await _animate_text_typing("you dont have this relic\nit is found at your first enemy", 0.25)
							3:
								await _animate_text_typing("you dont have this relic\nit is held at the end of a path", 0.25)
	
	ignore_input = false
	
	for key in menus.keys():
		if menus[key]["dialogue_option"] != null:
			menus[key]["dialogue_option"].modulate.a = 1.0
	
	# put back the main cursor
	menus["main"]["cursor"].text = "\n".repeat(menus["main"]["index"]) + ">"

func _animate_text_typing(typing_string: String, keystroke_time_range: float):
	
	var encrypted_typing_string = Globals.translate_to_interface(typing_string)
	_set_active_menu("main")
	
	await get_tree().create_timer(0.3).timeout
	dialogue_response.text = ""
	dialogue_encrypted_response.text = ""
	await get_tree().create_timer(0.2).timeout
	
	_internal_typing_func_dont_use_elsewhere(encrypted_typing_string, dialogue_encrypted_response, keystroke_time_range - 0.05)
	
	await get_tree().create_timer(1.0).timeout
	
	#_internal_typing_func_dont_use_elsewhere(typing_string, dialogue_response, keystroke_time_range)
	for i in range(typing_string.length()):
		await get_tree().create_timer(randf_range(keystroke_time_range, keystroke_time_range + 0.05)).timeout
		
		dialogue_response.text += typing_string[i]

func _internal_typing_func_dont_use_elsewhere(typing_string: String, label_node: Label, keystroke_time_range: float):
	for i in range(typing_string.length()):
		await get_tree().create_timer(randf_range(keystroke_time_range, keystroke_time_range + 0.05)).timeout
		
		label_node.text += typing_string[i]
		
		Globals._play_fx(audio_player, type, 0.0, randf_range(0.7, 1.4))

func _flicker():
	screen_material.emission_energy_multiplier = randf_range(0.3, 0.8)
	
	screen_material.albedo_color = Color(0.0, 0.0, 0.0, 0.0)
	screen_material.emission = Color(0.0, 0.0, 0.0, 0.0)
	screen_material.emission_enabled = true
	
	if !player_is_interacting:
		Globals._play_fx(audio_player, static_sound, -10.0, randf_range(0.5, 1.5))
	
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
		
		# save model position rest here to allow time for node to be relatively positioned
		if model_position_rest == null:
			model_position_rest = model.global_position

func _on_outer_area_3d_body_exited(body: Node3D) -> void:
	if body.name.contains("Player"):
		player_is_close = false

var tween = create_tween()

func _on_inner_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		player_is_interacting = true
		
		Globals._play_fx(audio_player, boot, 0.0, 1.0)
		
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
		
		Globals._play_fx(audio_player, shutdown, 0.0, 1.0)
		
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



# from enemt.gd (modified)
func _face_to_vector3(point: Vector3) -> void:
	# get the relative position of the point from the agent
	var to_point = (point - model.global_position).normalized()
	
	# get the angle from the point
	var angle_y = atan2(to_point.x, to_point.z) + (PI / 2) # add a 90deg offset
	
	# model.rotation.y = lerp_angle(model.rotation.y, angle_y, 0.5)
	
	tween.parallel().tween_property(model, "rotation:y", angle_y, 1.5)
