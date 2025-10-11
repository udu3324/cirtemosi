extends Node3D

var transitioning: bool = false


var tween = create_tween()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		Globals.player_death_event = "floor_death"


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
		transitioning = !transitioning
		print("player transitioning state is ", transitioning)


func _on_area_3d_2_exit_4_2_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and transitioning:
		transitioning = false
		Globals.player_level_load_event = "4.1->4.2"
