extends Node3D

@onready var shard_stack: Node3D = $HiddenStackOfShards

func _ready() -> void:
	if Globals.collected_shard_stack:
		remove_child(shard_stack)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		print_debug("entering to level 3")
		Globals.player_level_traverse_event = "4.1->3"


func _on_area_3d_2_title_card_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and !Globals.card_ruins_shown:
		Globals._show_title_card("Ruins", "Future Civilization", 0.8)
		Globals.card_ruins_shown = true


func _on_area_3d_collected_shard_stack_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		Globals.collected_shard_stack = true
