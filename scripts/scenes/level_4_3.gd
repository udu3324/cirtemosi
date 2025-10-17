extends Node3D

@onready var relic: Node3D = $House/Relic4

@onready var door: Node3D = $House/HiddenSides/Node3DDoorSwivel

@onready var house_foreground: CSGPolygon3D = $House/HouseTopSideForeground
@onready var hidden_room_sides: Node3D = $House/HiddenSides

var camera_tween = create_tween()
var door_tween = create_tween()

func _ready() -> void:
	if Globals.relics[3]:
		relic.queue_free()

func _on_area_3d_house_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		hidden_room_sides.visible = false
		house_foreground.visible = true
		
		if camera_tween.is_running():
			camera_tween.kill()
		
		camera_tween = create_tween()
		camera_tween.set_trans(Tween.TRANS_SINE)
		camera_tween.set_ease(Tween.EASE_IN_OUT)
		camera_tween.tween_property(Globals, "camera_size", 4.3, 1.0)


func _on_area_3d_house_body_exited(body: Node3D) -> void:
	if body.name.contains("Player"):
		hidden_room_sides.visible = true
		house_foreground.visible = false
		
		if camera_tween.is_running():
			camera_tween.kill()
		
		camera_tween = create_tween()
		camera_tween.set_trans(Tween.TRANS_SINE)
		camera_tween.set_ease(Tween.EASE_IN_OUT)
		camera_tween.tween_property(Globals, "camera_size", 5.762, 2.5)


func _on_area_3d_door_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		
		if door_tween.is_running():
			door_tween.kill()
		
		door_tween = create_tween()
		door_tween.set_trans(Tween.TRANS_SINE)
		door_tween.set_ease(Tween.EASE_IN_OUT)
		
		door_tween.tween_property(door, "rotation:y", deg_to_rad(-110.8), 1.0)

func _on_area_3d_door_body_exited(body: Node3D) -> void:
	if body.name.contains("Player"):
		
		if door_tween.is_running():
			door_tween.kill()
		
		door_tween = create_tween()
		door_tween.set_trans(Tween.TRANS_SINE)
		door_tween.set_ease(Tween.EASE_IN_OUT)
		
		door_tween.tween_property(door, "rotation:y", deg_to_rad(-18.3), 1.0)
