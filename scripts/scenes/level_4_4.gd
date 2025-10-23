extends Node3D

@onready var spiral: Node3D = $Spiral
@onready var obelisk: Node3D = $MasterObelisk

@onready var light_relic_1: OmniLight3D = $MasterObelisk/OmniLight3DRelic1
@onready var light_relic_2: OmniLight3D = $MasterObelisk/OmniLight3DRelic2
@onready var light_relic_3: OmniLight3D = $MasterObelisk/OmniLight3DRelic3
@onready var light_relic_4: OmniLight3D = $MasterObelisk/OmniLight3DRelic4

@onready var relic_1_model: Node3D = $MasterObelisk/relic_1
@onready var relic_2_model: Node3D = $MasterObelisk/relic_2

@onready var final_insert_container: CenterContainer = $MasterObelisk/FinalRelicInsert/SubViewport/FinalCenterContainer
@onready var final_light: OmniLight3D = $MasterObelisk/FinalRelicInsert/OmniLight3D
@onready var final_relic_model: Node3D = $MasterObelisk/FinalRelicInsert/relic_5

@onready var end_bg: Control = $Control

var obelisk_final_pos: Vector3

var handle_input: bool = false
var done: bool = false

func _ready() -> void:
	obelisk_final_pos = obelisk.global_position
	
	obelisk.global_position.y -= 8.5
	
	if Globals.final_relic_placement_ready:
		spiral.queue_free()
		
		# spiral animation already happened and player already has relic
	elif Globals.relics[4] and Globals.run_spiral_down_once:
		spiral.global_position.y -= 10
		obelisk.global_position.y += 8.5

func _process(_delta: float) -> void:
	if done:
		return
	
	if Globals.inserted_relic[0] and light_relic_1.light_energy != 4.5:
		light_relic_1.light_energy = 4.5
		relic_1_model.visible = true
	
	if Globals.inserted_relic[1] and light_relic_2.light_energy != 4.5:
		light_relic_2.light_energy = 4.5
		relic_2_model.visible = true
	
	if Globals.inserted_relic[2] and light_relic_3.light_energy != 4.5:
		light_relic_3.light_energy = 4.5
	
	if Globals.inserted_relic[3] and light_relic_4.light_energy != 4.5:
		light_relic_4.light_energy = 4.5
	
	if Globals.inserted_relic[0] and Globals.inserted_relic[1] and Globals.inserted_relic[2] and Globals.inserted_relic[3] and !Globals.final_relic_placement_ready:
		Globals.final_relic_placement_ready = true
		var tween = create_tween()
		tween.tween_property(obelisk, "position:y", -8.5, 8.0)
	
	if !handle_input:
		return
	
	if Input.is_action_just_pressed("attack"):
		print("finished game..")
		
		done = true
		Globals.player_can_move = false
		
		final_insert_container.visible = false
		final_relic_model.visible = true
		
		var tween = create_tween()
		tween.tween_property(final_light, "light_energy", 4.5, 3.0)
		tween.tween_property(final_light, "light_energy", 2.5, 3.0)
		tween.tween_property(final_light, "light_energy", 4.5, 3.0)
		tween.tween_property(final_light, "light_energy", 2.5, 3.0)
		
		await tween.finished
		
		tween = create_tween()
		tween.tween_property(end_bg, "modulate:a", 255, 3.0)
		
		#todo game done

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and !Globals.run_spiral_down_once:
		Globals.run_spiral_down_once = true
		
		var tween = create_tween()
		tween.tween_property(spiral, "position:y", -10.0, 5.0)
		
		await tween.finished
		
		tween = create_tween()
		tween.tween_property(obelisk, "global_position", obelisk_final_pos, 5.0)


func _on_area_3d_last_insert_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and !done:
		final_insert_container.visible = true
		handle_input = true


func _on_area_3d_last_insert_body_exited(body: Node3D) -> void:
	if body.name.contains("Player"):
		final_insert_container.visible = false
		handle_input = false
