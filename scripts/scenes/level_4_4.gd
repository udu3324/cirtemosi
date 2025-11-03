extends Node3D

@onready var spiral: Node3D = $Spiral
@onready var obelisk: Node3D = $MasterObelisk

@onready var light_relic_1: OmniLight3D = $MasterObelisk/OmniLight3DRelic1
@onready var light_relic_2: OmniLight3D = $MasterObelisk/OmniLight3DRelic2
@onready var light_relic_3: OmniLight3D = $MasterObelisk/OmniLight3DRelic3
@onready var light_relic_4: OmniLight3D = $MasterObelisk/OmniLight3DRelic4

@onready var relic_1_model: Node3D = $MasterObelisk/relic_1
@onready var relic_2_model: Node3D = $MasterObelisk/relic_2

@onready var final_insert_area: Area3D = $MasterObelisk/FinalRelicInsert/Area3DLastInsert
@onready var final_insert_container: CenterContainer = $MasterObelisk/FinalRelicInsert/SubViewport/FinalCenterContainer
@onready var final_light: OmniLight3D = $MasterObelisk/FinalRelicInsert/OmniLight3D
@onready var final_relic_model: Node3D = $MasterObelisk/FinalRelicInsert/relic_5

@onready var end_ui: Control = $Control
@onready var end_bg: ColorRect = $Control/MarginContainer/ColorRect
@onready var end_label: Label = $Control/MarginContainer/CenterContainer/Label2

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
var type = preload("res://assets/audio/fx/interface_untranslated.wav")

var obelisk_final_pos: Vector3
var obelisk_settled_pos: Vector3

var handle_input: bool = false
var done: bool = false

func _ready() -> void:
	obelisk_final_pos = obelisk.global_position
	
	obelisk.global_position.y -= 8.5
	
	obelisk_settled_pos = obelisk.global_position
	
	if Globals.final_relic_placement_ready:
		spiral.queue_free()
		
		# spiral animation already happened and player already has relic
	elif Globals.relics[4] and Globals.run_spiral_down_once:
		spiral.queue_free()
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
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(obelisk, "global_position", obelisk_settled_pos, 18.0)
		
		await tween.finished
		
		# the player may walk into the area 3d triggering enter but condition is false before animation has finished
		final_insert_area.monitoring = false
		await get_tree().process_frame
		final_insert_area.monitoring = true
	
	if !handle_input:
		return
	
	if Input.is_action_just_pressed("attack"):
		print("finished game..")
		
		done = true
		Globals.player_can_move = false
		
		final_insert_container.visible = false
		final_relic_model.visible = true
		
		Globals.hide_ui_event = true
		
		_async_run_tween()
		_async_run_tween2()
		
		await _animate_text_typing(tr("the relics have been found"), 0.25)
		await get_tree().create_timer(2.0).timeout
		await _animate_text_typing(tr("put back in the obelisk"), 0.20)
		await get_tree().create_timer(2.0).timeout
		await _animate_text_typing(tr("power lost from generations before return"), 0.25)
		await get_tree().create_timer(2.0).timeout
		await _animate_text_typing(tr("you have been transcended\nback to the surface"), 0.20)
		await get_tree().create_timer(2.0).timeout
		
		end_bg.visible = true
		var tween = create_tween()
		tween.tween_property(end_bg, "color:a", 1.0, 5.0)
		
		await tween.finished
		await get_tree().create_timer(2.0).timeout
		
		end_label.text = ""
		end_bg.color = Color(0, 0, 0, 1)
		
		await get_tree().create_timer(0.2).timeout
		
		Globals.credits_trigger_enter = true

func _animate_text_typing(typing_string: String, keystroke_time_range: float):
	
	await get_tree().create_timer(0.3).timeout
	end_label.text = ""
	await get_tree().create_timer(0.2).timeout
	
	for i in range(typing_string.length()):
		await get_tree().create_timer(randf_range(keystroke_time_range, keystroke_time_range + 0.05)).timeout
		
		Globals._play_fx(audio_player, type, 0.0, randf_range(0.7, 1.4))
		end_label.text += typing_string[i]

func _async_run_tween():
	var tween = create_tween()
	tween.tween_property(final_light, "light_energy", 4.5, 3.0)
	tween.tween_property(final_light, "light_energy", 1.5, 2.0)
	tween.tween_property(final_light, "light_energy", 4.9, 3.0)
	tween.tween_property(final_light, "light_energy", 2.0, 2.0)
	tween.tween_property(final_light, "light_energy", 4.5, 3.0)
	tween.tween_property(final_light, "light_energy", 1.5, 2.0)
	tween.tween_property(final_light, "light_energy", 4.9, 3.0)
	tween.tween_property(final_light, "light_energy", 2.0, 2.0)
	tween.tween_property(final_light, "light_energy", 4.5, 3.0)
	tween.tween_property(final_light, "light_energy", 1.5, 2.0)
	tween.tween_property(final_light, "light_energy", 4.9, 3.0)
	tween.tween_property(final_light, "light_energy", 2.0, 2.0)
	tween.tween_property(final_light, "light_energy", 4.5, 3.0)
	tween.tween_property(final_light, "light_energy", 1.5, 2.0)
	tween.tween_property(final_light, "light_energy", 4.9, 3.0)
	tween.tween_property(final_light, "light_energy", 2.0, 2.0)
	tween.tween_property(final_light, "light_energy", 4.5, 3.0)
	tween.tween_property(final_light, "light_energy", 1.5, 2.0)
	tween.tween_property(final_light, "light_energy", 4.9, 3.0)
	tween.tween_property(final_light, "light_energy", 2.0, 2.0)

func _async_run_tween2():
	var start_y = final_relic_model.position.y
	
	var tween = create_tween()
	tween.tween_property(final_relic_model, "position:y", start_y + 0.1, 2.0)
	tween.tween_property(final_relic_model, "position:y", start_y - 0.1, 3.0)
	tween.tween_property(final_relic_model, "position:y", start_y + 0.12, 2.0)
	tween.tween_property(final_relic_model, "position:y", start_y - 0.12, 3.0)
	tween.tween_property(final_relic_model, "position:y", start_y + 0.1, 2.0)
	tween.tween_property(final_relic_model, "position:y", start_y - 0.1, 3.0)
	tween.tween_property(final_relic_model, "position:y", start_y + 0.12, 2.0)
	tween.tween_property(final_relic_model, "position:y", start_y - 0.12, 3.0)
	tween.tween_property(final_relic_model, "position:y", start_y + 0.1, 2.0)
	tween.tween_property(final_relic_model, "position:y", start_y - 0.1, 3.0)
	tween.tween_property(final_relic_model, "position:y", start_y + 0.12, 2.0)
	tween.tween_property(final_relic_model, "position:y", start_y - 0.12, 3.0)
	tween.tween_property(final_relic_model, "position:y", start_y + 0.1, 2.0)
	tween.tween_property(final_relic_model, "position:y", start_y - 0.1, 3.0)
	tween.tween_property(final_relic_model, "position:y", start_y + 0.12, 2.0)
	tween.tween_property(final_relic_model, "position:y", start_y - 0.12, 3.0)
	tween.tween_property(final_relic_model, "position:y", start_y + 0.1, 2.0)
	tween.tween_property(final_relic_model, "position:y", start_y - 0.1, 3.0)
	tween.tween_property(final_relic_model, "position:y", start_y + 0.12, 2.0)
	tween.tween_property(final_relic_model, "position:y", start_y - 0.12, 3.0)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and !Globals.run_spiral_down_once:
		Globals.run_spiral_down_once = true
		
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(spiral, "position:y", -10.0, 5.0)
		
		await tween.finished
		spiral.queue_free()
		
		tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(obelisk, "global_position", obelisk_final_pos, 15.0)


func _on_area_3d_last_insert_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and !done and Globals.final_relic_placement_ready and obelisk.global_position.y < -6.3:
		final_insert_container.visible = true
		handle_input = true


func _on_area_3d_last_insert_body_exited(body: Node3D) -> void:
	if body.name.contains("Player"):
		final_insert_container.visible = false
		handle_input = false


func _on_area_3d_card_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and !Globals.card_obelisk_shown:
		Globals._show_title_card(tr("Final Obelisk"), "The abandoned structure", 0.5)
		Globals.card_obelisk_shown = true
