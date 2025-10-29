extends Node3D


@onready var draw_bridge: Node3D = $DrawBridge/DrawBridgePivot

@onready var electrical_wire_1: CSGPolygon3D = $DrawBridge/CSGPolygon3D3
@onready var electrical_wire_mat_1: StandardMaterial3D = electrical_wire_1.material
@onready var electrical_sprite_1: Sprite3D = $DrawBridge/ElectricalBox/Sprite3D

@onready var electrical_wire_2: CSGPolygon3D = $DrawBridge/CSGPolygon3D4
@onready var electrical_wire_mat_2: StandardMaterial3D = electrical_wire_2.material
@onready var electrical_sprite_2: Sprite3D = $DrawBridge/ElectricalBox2/Sprite3D


var transitioning: bool = false
var transitioning_2: bool = false
var transitioning_3: bool = false

var tween = create_tween()


var dont_need_to_process: bool = false

func _ready() -> void:
	if Globals.electrical_box_1:
		electrical_wire_mat_1.emission_enabled = true
	
	if Globals.electrical_box_2:
		electrical_wire_mat_2.emission_enabled = true
	
	if Globals.electrical_box_1 and Globals.electrical_box_2:
		draw_bridge.rotation.x = deg_to_rad(90)

func _process(_delta: float) -> void:
	if dont_need_to_process:
		return
	
	if electrical_sprite_1.visible:
		if Input.is_action_just_pressed("attack"):
			print("activated electrical box 1")
			electrical_sprite_1.visible = false
			Globals.electrical_box_1 = true
			electrical_wire_mat_1.emission_enabled = true
	
	if electrical_sprite_2.visible:
		if Input.is_action_just_pressed("attack"):
			print("activated electrical box 2")
			electrical_sprite_2.visible = false
			Globals.electrical_box_2 = true
			electrical_wire_mat_2.emission_enabled = true
	
	if Globals.electrical_box_1 and Globals.electrical_box_2:
		dont_need_to_process = true
		
		var tween_rot = create_tween()
		tween_rot.set_trans(Tween.TRANS_SINE)
		tween_rot.set_ease(Tween.EASE_IN_OUT)
		tween_rot.tween_property(draw_bridge, "rotation:x", deg_to_rad(90), 15.0)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		Globals.player_death_event = "floor_death"
	elif body.name.contains("Enemt") or body.name.contains("Zert"):
		body.health = 0.0
		Globals.shards += randi_range(3, 5) # give back player shards
		#print_debug("enemt fell to death")


func _on_area_3d_2_zoom_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		
		if tween.is_running():
			tween.kill()
		
		tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(Globals, "camera_size", 11.0, 1.5)
		


func _on_area_3d_2_zoom_body_exited(body: Node3D) -> void:
	if body.name.contains("Player"):
		
		if tween.is_running():
			tween.kill()
			
		tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(Globals, "camera_size", 5.762, 1.5)

func _on_area_3d_exit_4_1_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and transitioning:
		transitioning = false
		Globals.player_level_load_event = "4.2->4.1"


func _on_area_3d_mid_bridge_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		transitioning = true
		#print("player transitioning state is ", transitioning)
		var audio_tween = create_tween()
		audio_tween.tween_property(Globals.master_audio, "volume_db", -5.0, 1.0)


func _on_area_3d_2_exit_4_2_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and transitioning:
		transitioning = false
		Globals.player_level_load_event = "4.1->4.2"


func _on_area_3d_bridge_4_3_enter_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and transitioning_2:
		transitioning_2 = false
		Globals.player_level_load_event = "4.1->4.3"

func _on_area_3d_bridge_4_3_transition_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		transitioning_2 = true
		
		var audio_tween = create_tween()
		audio_tween.tween_property(Globals.master_audio, "volume_db", -5.0, 1.0)

func _on_area_3d_bridge_4_1_enter_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and transitioning_2:
		transitioning_2 = false
		Globals.player_level_load_event = "4.3->4.1"

func _on_area_3d_electrical_box_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and !Globals.electrical_box_1:
		electrical_sprite_1.visible = true

func _on_area_3d_electrical_box_body_exited(body: Node3D) -> void:
	if body.name.contains("Player"):
		electrical_sprite_1.visible = false


func _on_area_3d_electrical_box_2_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and !Globals.electrical_box_2:
		electrical_sprite_2.visible = true

func _on_area_3d_electrical_box_2_body_exited(body: Node3D) -> void:
	if body.name.contains("Player"):
		electrical_sprite_2.visible = false


func _on_area_3d_transition_4_4_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		transitioning_3 = true
		
		var audio_tween = create_tween()
		audio_tween.tween_property(Globals.master_audio, "volume_db", -5.0, 1.0)

func _on_area_3d_exit_4_4_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and transitioning_3:
		transitioning_3 = false
		Globals.player_level_load_event = "4.4->4.1"

func _on_area_3d_3_enter_4_4_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and transitioning_3:
		transitioning_3 = false
		Globals.player_level_load_event = "4.1->4.4"
