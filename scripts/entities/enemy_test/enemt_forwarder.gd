extends Node3D

@export var drops_relic_1: bool = false

func _ready():
	get_child(1).drops_relic_1 = drops_relic_1
