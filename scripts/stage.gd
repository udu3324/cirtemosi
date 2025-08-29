extends Node

@onready var menuStart = $CanvasLayer/MenuStart
@onready var menuPause = $CanvasLayer/MenuPause

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
	level = preload("res://levels/test_scene_1.tscn").instantiate()
	$Node3D.add_child(level)
	
	_add_player(Vector3(0, 2, 0))
	health.visible = true
	stamina.visible = true
	
	_add_environment()
	
	# do not always apply this to every scenario!!!
	Globals.stamina = Globals.stamina_max
	Globals.health = Globals.health_max
	
	print_debug("added level 1")

func _add_player(pos: Vector3):
	player = preload("res://entities/player.tscn").instantiate()
	player.position = pos
	$Node3D.add_child(player)
	
	print_debug("added player")

func _add_environment():
	enviornment = preload("res://scenes/enviornment/OutsideEnv.tscn").instantiate()
	$Node3D.add_child(enviornment)
	
	print_debug("added enviornment")
