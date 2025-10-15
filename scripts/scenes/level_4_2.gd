extends Node3D


@onready var bridge_1: Node3D = $StructurePuzzle/BridgePuzzleAnchor
@onready var bridge_2: Node3D = $StructurePuzzle/BridgePuzzleAnchor2

@onready var hidden_text_1: CenterContainer = $HiddenSwitch1/SubViewport/CenterContainerMouse

@onready var oblisk_piece: RigidBody3D = $Towers/RigidBody3DOblieskPiece

var oblisk_piece_original_pos: Vector3
var oblisk_piece_final_pos: Vector3

var listen_for_click_1 = false

func _ready() -> void:
	if Globals.bridge_1_down:
		var tween = create_tween()
		tween.tween_property(bridge_1, "rotation:z", 0, 2.0)
	
	if Globals.bridge_2_down:
		var tween = create_tween()
		tween.tween_property(bridge_2, "rotation:z", 0, 2.0)
	
	oblisk_piece_final_pos = oblisk_piece.global_position
	oblisk_piece_final_pos.x += 1.5
	oblisk_piece_final_pos.z += 0.5
	
	oblisk_piece_original_pos = oblisk_piece.global_position

func _process(_delta: float) -> void:
	
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
			tween.tween_property(oblisk_piece, "global_position", final_pos, 2.0)
			
			var tween2 = create_tween()
			tween2.tween_property(bridge_2, "rotation:z", 0, 2.0)
		
		if distance > 3.0:
			# bro
			oblisk_piece.sleeping = true
			oblisk_piece.freeze = true
			
			var tween = create_tween()
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
		hidden_text_1.visible = true


func _on_area_3d_title_card_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and !Globals.card_structures_shown:
		Globals._show_title_card("Structures", "What society depended on.", 0.5)
		Globals.card_structures_shown = true
	
	if body.name.contains("Player"):
		Globals.save_point = 4.2
