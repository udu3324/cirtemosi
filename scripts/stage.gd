extends Node

@onready var masterAudio = $AudioStreamPlayer


@onready var menuStart = $CanvasLayer/MenuStart
@onready var menuPause = $CanvasLayer/MenuPause
@onready var menuReset = $CanvasLayer/MenuReset

@onready var menuLoading = $CanvasLayer/Loading

@onready var audio_menu_pick = $MenuFX
@onready var booh = preload("res://assets/audio/fx/menu_pick.wav")

@onready var regular = preload("res://assets/audio/soundtrack/cirtemosi-start-remixed.ogg")

@onready var vignette = $CanvasLayer/Vignette/MarginContainer/ColorRect
@onready var health = $CanvasLayer/HealthBar
@onready var stamina = $CanvasLayer/StaminaBar
@onready var equipment = $CanvasLayer/Equipment
@onready var relics = $CanvasLayer/Relics
@onready var shards = $CanvasLayer/Shards

@onready var hints = $CanvasLayer/ControllerHints/MarginContainer/VBoxContainer

@onready var level_start = $LevelStartMenu

@onready var title_card = $CanvasLayer/TitleCard
@onready var title_crypt = $CanvasLayer/TitleCard/CenterContainer/VBoxContainer/VBoxContainer/TitleEncrypted
@onready var description_crypt = $CanvasLayer/TitleCard/CenterContainer/VBoxContainer/VBoxContainer/DescriptionEncrypted
@onready var title_decrypt = $CanvasLayer/TitleCard/CenterContainer/VBoxContainer/TitleDecrypted

@onready var arcade_ui = $CanvasLayer/Arcade
@onready var arcade_ui_title = $CanvasLayer/Arcade/MarginContainer/Title
@onready var arcade_ui_description = $CanvasLayer/Arcade/MarginContainer2/Description
@onready var arcade_ui_time = $CanvasLayer/Arcade/MarginContainer3/Time

var level
var player
var enviornment

func _ready() -> void:
	Globals.master_audio = masterAudio
	Globals.root_node_3d = $Node3D
	
	Globals.title_card = title_card
	
	Globals.title_crypt = title_crypt
	Globals.description_crypt = description_crypt
	Globals.title_decrypt = title_decrypt
	
	Globals.arcade_title = arcade_ui_title
	Globals.arcade_description = arcade_ui_description
	Globals.arcade_time = arcade_ui_time
	# in case i forget to do it in editor :cry:
	Globals.arcade_title.text = ""
	Globals.arcade_description.text = ""
	Globals.arcade_time.text = ""
	
	menuPause.connect("exit_to_start", _on_exit_start)
	menuReset.connect("exit_to_start", _on_exit_start)
	menuReset.connect("to_checkpoint", _to_checkpoint)
	
	if Globals.debug_mode:
		menuStart.connect("level_1", _on_level_test)
		menuStart.connect("level_arcade", _on_level_1)
	else:
		menuStart.connect("level_1", _on_level_1)
		menuStart.connect("level_arcade", _on_level_arcade)
	
	menuStart.visible = true
	
	masterAudio.play()
	masterAudio.volume_db = -5.0

func _process(_delta: float) -> void:
	
	Globals.startVisible = menuStart.visible
	Globals.loadingVisible = menuLoading.visible
	Globals.resetVisible = menuReset.visible
	
	Globals.arcadeUIVisible = arcade_ui.visible
	
	if !masterAudio.playing:
		masterAudio.play()
	
	if Globals.player_vignette_event:
		_handle_vignette_event()
	
	if Globals.player_death_event != "":
		_handle_death_event()
	
	if Globals.player_level_traverse_event != "":
		_handle_level_traverse_event()
	
	if Globals.player_level_load_event != "":
		_handle_player_level_load_event()
	
	if Globals.menu_pick_fx_event != null:
		Globals._play_fx(audio_menu_pick, booh, Globals.menu_pick_fx_event, 1.0)
		Globals.menu_pick_fx_event = null
	
	_handle_input_controller_hints()
	
	if Globals.debug_mode:
		if Input.is_action_just_pressed("just_space_key"):
			print("debug gave equipment and save point and more")
			Globals.save_point = 4.2
			Globals.equipment = ["starter_weapon", "bow", ""]
			Globals.shards += 999
			Globals.health = Globals.health_max
			Globals.stamina = Globals.stamina_max


func _handle_input_controller_hints():
	if Input.is_action_pressed("ui_up"):
		hints.get_child(0).visible = false
	
	if Input.is_action_pressed("ui_left"):
		hints.get_child(1).visible = false
	
	if Input.is_action_pressed("ui_down"):
		hints.get_child(2).visible = false
	
	if Input.is_action_pressed("ui_right"):
		hints.get_child(3).visible = false
	
	if Input.is_action_pressed("sprint"):
		hints.get_child(4).visible = false
	
	if Input.is_action_pressed("attack"):
		hints.get_child(5).visible = false
	
	if Input.is_action_pressed("switch"):
		hints.get_child(6).visible = false
	
	if Globals.hint_attack_switch_control_event:
		hints.get_child(5).visible = true
		hints.get_child(6).visible = true
		
		Globals.hint_attack_switch_control_event = false

func _handle_vignette_event():
	Globals.player_vignette_event = false
	
	# vignette has been triggered while its already running
	if vignette.material.get_shader_parameter("opacity") != 0.0:
		return
	
	# dont trigger if already dead
	if Globals.health <= 0.0:
		return
	
	var tween = create_tween()
	tween.tween_property(vignette.material, "shader_parameter/opacity", 1.0, 0.3)
	
	await get_tree().create_timer(0.8).timeout
	
	tween = create_tween()
	tween.tween_property(vignette.material, "shader_parameter/opacity", 0.0, 1.0)

func _handle_death_event():
	print_debug("recieved death event", Globals.player_death_event)
	
	if Globals.player_death_event == "floor_death":
		Globals.player_death_event = ""
		
		Globals.player_can_move = false
		Globals.player_physics_processing = false
		_show_reset_screen()
	elif Globals.player_death_event == "ran_out_of_hp":
		Globals.player_death_event = ""
		
		_show_reset_screen()
		
		await get_tree().create_timer(1).timeout
		
		Globals.player_can_move = false
		Globals.player_physics_processing = false

func _show_reset_screen():
	menuReset.modulate.a = 0.0
	menuReset.visible = true
	
	var tween = create_tween()
	tween.tween_property(menuReset, "modulate:a", 1.0, 1)
	
	var audioFade = create_tween()
	audioFade.tween_property(masterAudio, "volume_db", -10.0, 2)

func _handle_level_traverse_event():
	print_debug("recieved traverse event", Globals.player_level_traverse_event)
	
	# clear global so it doesn't run again
	var traversing_to: String = Globals.player_level_traverse_event
	Globals.player_level_traverse_event = ""
	
	await _show_loading()
	
	# level 1 triggers
	if traversing_to == "1->2": #next
		_clear_node_3d_stage()
		
		level = preload("res://levels/level2.tscn").instantiate()
		$Node3D.add_child(level)
	
		_add_player(Vector3(0, 2, 0))
	
	# level 2 triggers
	if traversing_to == "2->1": #back
		_clear_node_3d_stage()
		
		level = preload("res://levels/level1.tscn").instantiate()
		$Node3D.add_child(level)
	
		_add_player(Vector3(0, 1.5, -9.0))
	
	if traversing_to == "2->3": #next
		_clear_node_3d_stage()
		
		level = preload("res://levels/level3.tscn").instantiate()
		$Node3D.add_child(level)
	
		_add_player(Vector3(0, 1.5, 1.3))
	
	# level 3 triggers
	if traversing_to == "3->2": #back
		_clear_node_3d_stage()
		
		level = preload("res://levels/level2.tscn").instantiate()
		$Node3D.add_child(level)
	
		_add_player(Vector3(-13.5, 2.5, -25.5))
	
	if traversing_to == "testing": #lol
		_clear_node_3d_stage()
		
		_on_level_test()
	
	if traversing_to == "3->4.1": #next
		_clear_node_3d_stage()
		
		level = preload("res://levels/level4.tscn").instantiate()
		$Node3D.add_child(level)
		
		var sub_level = preload("res://levels/level4_1.tscn").instantiate()
		$Node3D.add_child(sub_level)
		sub_level.global_position = Vector3(-20, 0, 0)
	
		_add_player(Vector3(-28, 2.5, -5.5))
	
	# level 4.1 triggers
	if traversing_to == "4.1->3": #back
		_clear_node_3d_stage()
		
		level = preload("res://levels/level3.tscn").instantiate()
		$Node3D.add_child(level)
	
		_add_player(Vector3(15, 2, -14))
	
	# base wait time for loading screen
	await get_tree().create_timer(3.0).timeout 
	
	await _hide_loading()

func _handle_player_level_load_event():
	print_debug("recieved load event", Globals.player_level_load_event)
	
	# clear global so it doesn't run again
	var traversing_to: String = Globals.player_level_load_event
	Globals.player_level_load_event = ""
	
	match traversing_to:
		"4.1->4.2":
			var next = $Node3D.find_child("Level4_2", true, false)
			
			if $Node3D.find_child("Level4_1", true, false) != null:
				#print("freeing Level4_1")
				$Node3D.find_child("Level4_1", true, false).queue_free()
			
			if next != null: # player went back other direction
				#print("skipped load event")
				return
			
			var sub_level = preload("res://levels/level4_2.tscn").instantiate()
			$Node3D.add_child(sub_level)
		"4.2->4.1":
			var next = $Node3D.find_child("Level4_1", true, false)
			
			if $Node3D.find_child("Level4_2", true, false) != null:
				#print("freeing Level4_2")
				$Node3D.find_child("Level4_2", true, false).queue_free()
			
			if next != null: # player went back other direction
				#print("skipped load event")
				return
			
			var sub_level = preload("res://levels/level4_1.tscn").instantiate()
			sub_level.global_position = Vector3(-20, 0, 0)
			$Node3D.add_child(sub_level)
		"4.1->4.3":
			var next = $Node3D.find_child("Level4_3", true, false)
			
			if $Node3D.find_child("Level4_1", true, false) != null:
				#print("freeing Level4_1")
				$Node3D.find_child("Level4_1", true, false).queue_free()
			
			if next != null: # player went back other direction
				#print("skipped load event")
				return
			
			var sub_level = preload("res://levels/level4_3.tscn").instantiate()
			$Node3D.add_child(sub_level)
		"4.3->4.1":
			var next = $Node3D.find_child("Level4_1", true, false)
			
			if $Node3D.find_child("Level4_3", true, false) != null:
				#print("freeing Level4_2")
				$Node3D.find_child("Level4_3", true, false).queue_free()
			
			if next != null: # player went back other direction
				#print("skipped load event")
				return
			
			var sub_level = preload("res://levels/level4_1.tscn").instantiate()
			sub_level.global_position = Vector3(-20, 0, 0)
			$Node3D.add_child(sub_level)

func _to_checkpoint():
	Globals.stamina = Globals.stamina_max - (Globals.stamina_max / 5)
	Globals.health = Globals.health_max - (Globals.health_max / 5)
	
	Globals.enemt_deaths = Globals.enemt_death_cleared
	Globals.zert_deaths = Globals.zert_death_cleared
	
	menuReset.visible = false
	
	match Globals.save_point:
		-1.0:
			pass # ????? this would never happen.. unless
		4.1:
			# cheap way
			Globals.player_level_traverse_event = "3->4.1"
		4.2:
			await _show_loading()
			_clear_node_3d_stage()
		
			level = preload("res://levels/level4.tscn").instantiate()
			$Node3D.add_child(level)
		
			var sub_level = preload("res://levels/level4_2.tscn").instantiate()
			$Node3D.add_child(sub_level)
	
			_add_player(Vector3(-1, 0.0, -24))
			
			# base wait time for loading screen
			await get_tree().create_timer(3.0).timeout 
	
			await _hide_loading()

func _on_exit_start():
	Globals.player_pos = Vector3(0, 0, 0)
	Globals.player_physics_processing = true
	Globals.player_can_move = true
	
	_clear_node_3d_stage()
	
	masterAudio.stream = regular
	
	for hint in hints.get_children():
		hint.visible = false
	
	arcade_ui.visible = false
	
	menuPause.visible = false
	menuReset.visible = false
	
	
	health.visible = false
	stamina.visible = false
	equipment.visible = false
	relics.visible = false
	shards.visible = false
	
	Globals.arcade_description.text = ""
	Globals.arcade_title.text = ""
	
	Globals.equipment = ["", "", ""]
	Globals.enemt_deaths = Globals.enemt_death_cleared
	Globals.zert_deaths = Globals.zert_death_cleared
	Globals.slot_active = 1
	
	Globals.relics = [false, false, false, false, false, false, false]
	Globals.shards = 0
	
	Globals.item_info_dict["starter_weapon"]["damage"] = 20
	
	Globals.card_ruins_shown = false
	Globals.card_structures_shown = false
	Globals.collected_shard_stack = false
	Globals.bridge_1_down = false
	Globals.bridge_2_down = false
	Globals.electrical_box_1 = false
	Globals.electrical_box_2 = false
	Globals.inserted_relic = [false, false, false, false, false]
	Globals.save_point = -1.0
	
	Globals.camera_size = 5.762
	
	
	
	get_tree().paused = false
	
	#print_debug("adding back the child")
	add_child(level_start)
	
	var audioFade = create_tween()
	audioFade.tween_property(masterAudio, "volume_db", -5.0, 2)
	
	
	# wait a while until making start visible as it will trigger a input from before to press a button
	# this is probably frame dependent.... #todo a better method
	await get_tree().create_timer(0.01).timeout
	menuStart.visible = true

func _on_level_1():
	await _show_loading()
	
	level = preload("res://levels/level1.tscn").instantiate()
	$Node3D.add_child(level)
	
	remove_child(level_start)
	
	_add_player(Vector3(0, 2, 0))
	health.visible = true
	stamina.visible = true
	equipment.visible = true
	relics.visible = true
	shards.visible = true
	
	# only for the test env
	# _add_environment(preload("res://scenes/enviornment/OutsideEnv.tscn"))
	
	# do not always apply this to every scenario!!!
	Globals.stamina = Globals.stamina_max
	Globals.health = Globals.health_max
	
	await get_tree().create_timer(1).timeout # additional waiting time
	_hide_loading()
	
	print_debug("added level 1")
	
	await Globals._show_title_card("The Cave", "you mistakenly came here", 1.0)
	
	await get_tree().create_timer(0.1).timeout
	
	hints.get_child(0).visible = true
	hints.get_child(1).visible = true
	hints.get_child(2).visible = true
	hints.get_child(3).visible = true
	hints.get_child(4).visible = true

func _on_level_arcade():
	await _show_loading()
	
	level = preload("res://levels/arcade/levelbase.tscn").instantiate()
	$Node3D.add_child(level)
	
	remove_child(level_start)
	
	_add_player(Vector3(0, 2, 0))
	health.visible = true
	stamina.visible = true
	equipment.visible = true
	#relics.visible = true
	shards.visible = true
	
	arcade_ui.visible = true
	
	# do not always apply this to every scenario!!!
	Globals.stamina = Globals.stamina_max
	Globals.health = Globals.health_max
	
	_hide_loading()
	
	print_debug("added arcade level 1")
	
	#await Globals._show_title_card("Arcade Mode", "have fun!", 0.3)
	
	#await get_tree().create_timer(0.4).timeout
	
	hints.get_child(0).visible = true
	hints.get_child(1).visible = true
	hints.get_child(2).visible = true
	hints.get_child(3).visible = true
	hints.get_child(4).visible = true
	
	masterAudio.stream = null
	
	Globals.arcade_title.text = "cross the bridge"
	Globals.arcade_time.text = ""
	Globals.arcade_description.text = ""
	
	_hide_loading()
	
	
	

func _on_level_test():
	level = preload("res://levels/test/test_scene_1.tscn").instantiate()
	$Node3D.add_child(level)
	
	remove_child(level_start)
	
	_add_player(Vector3(0, 2, 0))
	health.visible = true
	stamina.visible = true
	equipment.visible = true
	relics.visible = true
	shards.visible = true
	
	Globals.player_is_stunned = false
	
	_add_environment(preload("res://scenes/enviornment/CaveEnv.tscn"))
	
	# do not always apply this to every scenario!!!
	Globals.stamina = Globals.stamina_max
	Globals.health = Globals.health_max
	
	print_debug("added test level")

func _add_player(pos: Vector3):
	player = preload("res://entities/player.tscn").instantiate()
	player.name = "Player" + str(randi())
	player.position = pos
	$Node3D.add_child(player)
	
	print_debug("added player")

func _add_environment(sceneFile: Resource):
	enviornment = sceneFile.instantiate()
	$Node3D.add_child(enviornment)
	
	print_debug("added enviornment")

func _show_loading():
	Globals.stamina_regeneration = false
	Globals.player_can_move = false
	menuLoading.modulate.a = 0.0
	menuLoading.visible = true
	
	var tween = create_tween()
	tween.tween_property(menuLoading, "modulate:a", 1.0, 1)
	
	var audioFade = create_tween()
	audioFade.tween_property(masterAudio, "volume_db", -10.0, 2)
	
	await get_tree().create_timer(1).timeout # tween length

func _hide_loading():
	var audioFade = create_tween()
	audioFade.tween_property(masterAudio, "volume_db", 0, 2)
	
	var tween = create_tween()
	tween.tween_property(menuLoading, "modulate:a", 0.0, 1)
	
	Globals.player_physics_processing = true
	Globals.player_physics_reset_event = true
	Globals.player_is_stunned = false
	
	Globals.camera_size = 5.762
	
	await get_tree().create_timer(1).timeout # tween length
	Globals.player_can_move = true
	menuLoading.visible = false
	
	# punish stamina regeneration after traversing
	await get_tree().create_timer(Globals.stamina_recovery_time).timeout
	Globals.stamina_regeneration = true

func _clear_node_3d_stage():
	for node in $Node3D.get_children():
		node.queue_free()
