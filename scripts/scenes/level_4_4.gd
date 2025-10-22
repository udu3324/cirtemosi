extends Node3D

@onready var spiral: Node3D = $Spiral
@onready var obelisk: Node3D = $MasterObelisk

@onready var light_1: OmniLight3D = $MasterObelisk/OmniLight3D
@onready var light_2: OmniLight3D = $MasterObelisk/OmniLight3D2
@onready var light_3: OmniLight3D = $MasterObelisk/OmniLight3D3
@onready var light_4: OmniLight3D = $MasterObelisk/OmniLight3D4

var obelisk_final_pos: Vector3

func _ready() -> void:
	obelisk_final_pos = obelisk.global_position
	
	obelisk.global_position.y = obelisk.global_position.y - 8.5
	
	light_1.light_energy = 0.5
	light_2.light_energy = 0.5
	light_3.light_energy = 0.5
	light_4.light_energy = 0.5
	
	if Globals.relics[4]:
		#todo
		pass
