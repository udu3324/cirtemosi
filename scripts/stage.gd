extends Node

@onready var menuStart = $CanvasLayer/MenuStart

func _ready() -> void:
	menuStart.connect("level_1", _on_level_1)
	menuStart.visible = true;

func _process(delta: float) -> void:
	pass

func _on_level_1():
	var level = preload("res://levels/intro_fall.tscn").instantiate()
	$Node3D.add_child(level)
	
	_add_player(Vector3(0, 2, 0))
	
	print_debug("added level 1")

func _add_player(pos: Vector3):
	var player = preload("res://entities/player.tscn").instantiate()
	player.position = pos
	$Node3D.add_child(player)
	
	print_debug("added player")
