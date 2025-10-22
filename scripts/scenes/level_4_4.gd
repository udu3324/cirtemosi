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
	
	obelisk.global_position.y -= 8.5
	
	light_1.light_energy = 0.5
	light_2.light_energy = 0.5
	light_3.light_energy = 0.5
	light_4.light_energy = 0.5
	
	# spiral animation already happened and player already has relic
	if Globals.relics[4] and Globals.run_spiral_down_once:
		spiral.global_position.y -= 10
		obelisk.global_position.y += 8.5

func _process(_delta: float) -> void:
	if Globals.inserted_relic[0]:
		light_1.light_energy = 4.5
	elif Globals.inserted_relic[1]:
		light_3.light_energy = 4.5
	elif Globals.inserted_relic[2]:
		light_2.light_energy = 4.5
	elif Globals.inserted_relic[3]:
		light_4.light_energy = 4.5

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and !Globals.run_spiral_down_once:
		Globals.run_spiral_down_once = true
		
		var tween = create_tween()
		tween.tween_property(obelisk, "global_position", obelisk_final_pos, 4.0)
		
		await tween.finished
		
		tween = create_tween()
		tween.tween_property(spiral, "position:y", -10.0, 8.0)
