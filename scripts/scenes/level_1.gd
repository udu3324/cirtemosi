extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		print_debug("entering to level 2")
		Globals.player_level_traverse_event = "3->4.1" # todo temp
