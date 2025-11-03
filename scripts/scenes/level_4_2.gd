extends Node3D

@onready var spot_light_follow: SpotLight3D = $Path/SpotLight3DFollow

@onready var relic_2: Node3D = $StructurePuzzle/Relic2

@onready var bridge_1: Node3D = $StructurePuzzle/BridgePuzzleAnchor
@onready var bridge_2: Node3D = $StructurePuzzle/BridgePuzzleAnchor2

@onready var hidden_text_1: CenterContainer = $StructurePuzzle/HiddenSwitch1/SubViewport/CenterContainerMouse

@onready var oblisk_piece: RigidBody3D = $PlatformStuff/Towers/RigidBody3DOblieskPiece

var spot_light_follow_original_pos: Vector3
var light_follow_player: bool = false

var oblisk_piece_original_pos: Vector3
var oblisk_piece_final_pos: Vector3

var listen_for_click_1 = false

var camera_tween = create_tween()

func _ready() -> void:
	if Globals.relics[1]:
		relic_2.queue_free()
	
	if Globals.bridge_1_down:
		bridge_1.rotation.z = 0
	
	if Globals.bridge_2_down:
		bridge_2.rotation.z = 0
	
	oblisk_piece_final_pos = oblisk_piece.global_position
	oblisk_piece_final_pos.x += 1.5
	oblisk_piece_final_pos.z += 0.5
	
	oblisk_piece_original_pos = oblisk_piece.global_position
	
	spot_light_follow_original_pos = spot_light_follow.global_position

func _process(_delta: float) -> void:
	
	if light_follow_player:
		var new_pos = Globals.player_pos
		new_pos.y = spot_light_follow_original_pos.y
		spot_light_follow.global_position = new_pos
	
	if !Globals.bridge_2_down:
		#DebugDraw3D.draw_sphere(oblisk_piece_final_pos, 0.3, Color.AQUA)
		var fix_pos = oblisk_piece.global_position
		fix_pos.y = oblisk_piece_final_pos.y
		var distance = fix_pos.distance_to(oblisk_piece_final_pos)
		
		#print("1 ", fix_pos)
		#print("2 ", oblisk_piece_final_pos)
		
		#print("current pos," + str(distance))
		if distance < 0.15:
			print("good")
			Globals.bridge_2_down = true
			
			oblisk_piece.sleeping = true
			oblisk_piece.freeze = true
			
			var final_pos = Vector3(3.428786, 2.0, -34.56116)
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_SINE)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(oblisk_piece, "global_position", final_pos, 2.0)
			
			var tween2 = create_tween()
			tween2.tween_property(bridge_2, "rotation:z", 0, 2.0)
		
		if distance > 3.0:
			# bro
			oblisk_piece.sleeping = true
			oblisk_piece.freeze = true
			
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_SINE)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(oblisk_piece, "global_position", oblisk_piece_original_pos, 2.0)
			
			await tween.finished
			
			oblisk_piece.sleeping = false
			oblisk_piece.freeze = false
	
	if listen_for_click_1:
		if Input.is_action_just_pressed("attack"):
			listen_for_click_1 = false
			
			Globals.bridge_1_down = true
			hidden_text_1.visible = false
			
			var tween = create_tween()
			tween.tween_property(bridge_1, "rotation:z", 0, 2.0)

func _on_area_3d_switch_1_body_entered(body: Node3D) -> void:
	if Globals.bridge_1_down:
		return
	
	if body.name.contains("Player"):
		listen_for_click_1 = true
		hidden_text_1.visible = true


func _on_area_3d_switch_1_body_exited(body: Node3D) -> void:
	if body.name.contains("Player"):
		listen_for_click_1 = false
		hidden_text_1.visible = false


func _on_area_3d_title_card_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and !Globals.card_structures_shown:
		Globals._show_title_card(tr("Structures"), "What society depended on.", 0.5)
		Globals.card_structures_shown = true
	
	if body.name.contains("Player"):
		Globals.save_point = 4.2


func _on_area_3d_camera_zoom_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		
		if camera_tween.is_running():
			camera_tween.kill()
		
		camera_tween = create_tween()
		camera_tween.set_trans(Tween.TRANS_SINE)
		camera_tween.set_ease(Tween.EASE_IN_OUT)
		camera_tween.tween_property(Globals, "camera_size", 10.0, 1.5)


func _on_area_3d_camera_zoom_body_exited(body: Node3D) -> void:
	if body.name.contains("Player"):
		
		if camera_tween.is_running():
			camera_tween.kill()
		
		camera_tween = create_tween()
		camera_tween.set_trans(Tween.TRANS_SINE)
		camera_tween.set_ease(Tween.EASE_IN_OUT)
		camera_tween.tween_property(Globals, "camera_size", 5.762, 1.5)


func _on_area_3d_light_follow_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		light_follow_player = true
		
		if camera_tween.is_running():
			camera_tween.kill()
		
		camera_tween = create_tween()
		camera_tween.set_trans(Tween.TRANS_SINE)
		camera_tween.set_ease(Tween.EASE_IN_OUT)
		camera_tween.tween_property(Globals, "camera_size", 7.762, 1.5)


func _on_area_3d_light_follow_body_exited(body: Node3D) -> void:
	if body.name.contains("Player"):
		light_follow_player = false
		
		var tween = create_tween()
		tween.tween_property(spot_light_follow, "global_position", spot_light_follow_original_pos, 1.0)
		
		if camera_tween.is_running():
			camera_tween.kill()
		
		camera_tween = create_tween()
		camera_tween.set_trans(Tween.TRANS_SINE)
		camera_tween.set_ease(Tween.EASE_IN_OUT)
		camera_tween.tween_property(Globals, "camera_size", 5.762, 1.5)
