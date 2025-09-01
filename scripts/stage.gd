extends Node

@onready var menuStart = $CanvasLayer/MenuStart
@onready var menuPause = $CanvasLayer/MenuPause
@onready var menuLoading = $CanvasLayer/Loading

@onready var health = $CanvasLayer/HealthBar
@onready var stamina = $CanvasLayer/StaminaBar

var level
var player
var enviornment

func _ready() -> void:
	menuPause.connect("settings_open", _on_settings_open)
	menuPause.connect("exit_to_start", _on_exit_start)
	
	menuStart.connect("level_1", _on_level_1)
	menuStart.visible = true

func _process(delta: float) -> void:
	Globals.startVisible = menuStart.visible
	Globals.loadingVisible = menuLoading.visible
	
	#print_debug(Globals.player_pos)
	
	if Globals.player_level_traverse_event == "":
		return
	
	print_debug("recieved traverse event", Globals.player_level_traverse_event)
	
	# clear global so it doesn't run again
	var traversing_to: String = Globals.player_level_traverse_event
	Globals.player_level_traverse_event = ""
	
	await _show_loading()
	
	# level 1 triggers
	if traversing_to == "1->2": #next
		for node in $Node3D.get_children():
			$Node3D.remove_child(node)
		
		level = preload("res://levels/level2.tscn").instantiate()
		$Node3D.add_child(level)
	
		_add_player(Vector3(0, 2, 0))
	
	# level 2 triggers
	if traversing_to == "2->1": #back
		for node in $Node3D.get_children():
			$Node3D.remove_child(node)
		
		level = preload("res://levels/level1.tscn").instantiate()
		$Node3D.add_child(level)
	
		_add_player(Vector3(0, 1.5, -9.0))
	
	if traversing_to == "2->3": #next
		for node in $Node3D.get_children():
			$Node3D.remove_child(node)
		
		level = preload("res://levels/level3.tscn").instantiate()
		$Node3D.add_child(level)
	
		_add_player(Vector3(0, 1.5, 1.3))
	
	# level 3 triggers
	if traversing_to == "3->2": #back
		for node in $Node3D.get_children():
			$Node3D.remove_child(node)
		
		level = preload("res://levels/level2.tscn").instantiate()
		$Node3D.add_child(level)
	
		_add_player(Vector3(-13.5, 2.5, -25.5))
	
	
	# base wait time for loading screen
	await get_tree().create_timer(3.0).timeout 
	var tween2 = create_tween()
	tween2.tween_property(menuLoading, "modulate:a", 0.0, 1)
	
	await _hide_loading()
	

func _on_settings_open():
	pass

func _on_exit_start():
	for node in $Node3D.get_children():
		$Node3D.remove_child(node)
	
	menuPause.visible = false
	menuStart.visible = true
	
	health.visible = false
	stamina.visible = false
	
	get_tree().paused = false

func _on_level_1():
	level = preload("res://levels/level1.tscn").instantiate()
	$Node3D.add_child(level)
	
	_add_player(Vector3(0, 2, 0))
	health.visible = true
	stamina.visible = true
	
	#_add_environment(preload("res://scenes/enviornment/CaveEnv.tscn"))
	
	# do not always apply this to every scenario!!!
	Globals.stamina = Globals.stamina_max
	Globals.health = Globals.health_max
	
	print_debug("added level 1")

func _on_level_test():
	level = preload("res://levels/test/test_scene_1.tscn").instantiate()
	$Node3D.add_child(level)
	
	_add_player(Vector3(0, 2, 0))
	health.visible = true
	stamina.visible = true
	
	_add_environment(preload("res://scenes/enviornment/OutsideEnv.tscn"))
	
	# do not always apply this to every scenario!!!
	Globals.stamina = Globals.stamina_max
	Globals.health = Globals.health_max
	
	print_debug("added test level")

func _add_player(pos: Vector3):
	player = preload("res://entities/player.tscn").instantiate()
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
	menuLoading.visible = true
	menuLoading.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(menuLoading, "modulate:a", 1.0, 1)
	
	await get_tree().create_timer(1).timeout # tween length

func _hide_loading():
	await get_tree().create_timer(1).timeout # tween length
	Globals.player_can_move = true
	menuLoading.visible = false
	
	# punish stamina regeneration after traversing
	await get_tree().create_timer(1).timeout
	Globals.stamina_regeneration = true
