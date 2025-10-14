extends Node3D


@onready var bridge_1: Node3D = $StructurePuzzle/BridgePuzzleAnchor
@onready var bridge_2: Node3D = $StructurePuzzle/BridgePuzzleAnchor2

@onready var hidden_text_1: CenterContainer = $HiddenSwitch1/SubViewport/CenterContainerMouse

var listen_for_click_1 = false

func _ready() -> void:
	if Globals.bridge_1_down:
		var tween = create_tween()
		tween.tween_property(bridge_1, "rotation:z", 0, 2.0)
	
	if Globals.bridge_2_down:
		var tween = create_tween()
		tween.tween_property(bridge_2, "rotation:z", 0, 2.0)

func _process(_delta: float) -> void:
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
