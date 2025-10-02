extends Node3D


var tween = create_tween()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		Globals.player_death_event = "floor_death"


func _on_area_3d_2_zoom_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		
		if tween.is_running():
			tween.kill()
		
		tween = create_tween()
		tween.tween_property(Globals, "camera_size", 11.0, 1)
		


func _on_area_3d_2_zoom_body_exited(body: Node3D) -> void:
	if body.name.contains("Player"):
		
		if tween.is_running():
			tween.kill()
			
		tween = create_tween()
		tween.tween_property(Globals, "camera_size", 5.762, 1)
