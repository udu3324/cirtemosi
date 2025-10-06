extends Node3D

@onready var starter_weapon: Node3D = $StarterWeapon

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Globals.equipment[0] == "starter_weapon" and starter_weapon.visible:
		starter_weapon.visible = false


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		print_debug("entering to level 2")
		Globals.player_level_traverse_event = "3->2"


func _on_area_3d_2_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		print_debug("entering to testing level")
		Globals.player_level_traverse_event = "testing"


func _on_area_3d_3_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		print_debug("entering to level 4")
		Globals.player_level_traverse_event = "3->4.1"


func _on_area_3d_4_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		Globals.player_death_event = "floor_death"
