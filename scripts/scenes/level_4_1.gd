extends Node3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		print_debug("entering to level 3")
		Globals.player_level_traverse_event = "4.1->3"


func _on_area_3d_2_title_card_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and !Globals.card_ruins_shown:
		Globals._show_title_card("Ruins", "Future Civilization", 0.8)
		Globals.card_ruins_shown = true
