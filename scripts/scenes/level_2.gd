extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		print_debug("entering to level 1")
		Globals.player_level_traverse_event = "2->1"


func _on_area_3d_2_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		print_debug("entering to level 3")
		Globals.player_level_traverse_event = "2->3"


func _on_area_3d_3_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		Globals.player_death_event = "floor_death"
