extends Node

@onready var masterAudio = $AudioStreamPlayer


@onready var menuStart = $CanvasLayer/MenuStart
@onready var menuPause = $CanvasLayer/MenuPause
@onready var menuReset = $CanvasLayer/MenuReset

@onready var menuLoading = $CanvasLayer/Loading

@onready var audio_menu_pick = $MenuFX
@onready var booh = preload("res://assets/audio/fx/menu_pick.wav")

@onready var vignette = $CanvasLayer/Vignette/MarginContainer/ColorRect
@onready var health = $CanvasLayer/HealthBar
@onready var stamina = $CanvasLayer/StaminaBar
@onready var equipment = $CanvasLayer/Equipment
@onready var relics = $CanvasLayer/Relics
@onready var shards = $CanvasLayer/Shards

@onready var hints = $CanvasLayer/ControllerHints/MarginContainer/VBoxContainer

@onready var level_start = $LevelStartMenu

var level
var player
var enviornment

func _ready() -> void:
	Globals.root_node_3d = $Node3D
	
	menuPause.connect("exit_to_start", _on_exit_start)
	menuReset.connect("exit_to_start", _on_exit_start)
	
	
	menuStart.connect("level_1", _on_level_1)
	menuStart.visible = true
	
	masterAudio.play()
	masterAudio.volume_db = -5.0

func _process(_delta: float) -> void:
	
	Globals.startVisible = menuStart.visible
	Globals.loadingVisible = menuLoading.visible
	Globals.resetVisible = menuReset.visible
	
	if !masterAudio.playing:
		masterAudio.play()
	
	if Globals.player_vignette_event:
		_handle_vignette_event()
	
	if Globals.player_death_event != "":
		_handle_death_event()
	
	if Globals.player_level_traverse_event != "":
		_handle_level_traverse_event()
	
	if Globals.menu_pick_fx_event != null:
		Globals._play_fx(audio_menu_pick, booh, Globals.menu_pick_fx_event, 1.0)
		Globals.menu_pick_fx_event = null
	
	_handle_input_controller_hints()

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

func _on_exit_start():
	Globals.player_pos = Vector3(0, 0, 0)
	
	_clear_node_3d_stage()
	
	for hint in hints.get_children():
		hint.visible = false
	
	menuPause.visible = false
	menuReset.visible = false
	
	
	health.visible = false
	stamina.visible = false
	equipment.visible = false
	relics.visible = false
	shards.visible = false
	
	Globals.equipment = ["", "", ""]
	Globals.slot_active = 1
	
	Globals.relics = [false, false, false, false, false, false, false]
	Globals.shards = 0
	
	get_tree().paused = false
	
	print_debug("adding back the child")
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
	
	await get_tree().create_timer(2).timeout # additional waiting time
	_hide_loading()
	
	print_debug("added level 1")
	
	hints.get_child(0).visible = true
	hints.get_child(1).visible = true
	hints.get_child(2).visible = true
	hints.get_child(3).visible = true
	hints.get_child(4).visible = true

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
	
	await get_tree().create_timer(1).timeout # tween length
	Globals.player_can_move = true
	menuLoading.visible = false
	
	# punish stamina regeneration after traversing
	await get_tree().create_timer(Globals.stamina_recovery_time).timeout
	Globals.stamina_regeneration = true

func _clear_node_3d_stage():
	for node in $Node3D.get_children():
		node.queue_free()
