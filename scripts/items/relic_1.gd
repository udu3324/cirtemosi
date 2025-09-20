extends RigidBody3D

@onready var audio_player = $AudioStreamPlayer3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player" and self.visible:
		print_debug("picked up relic 1")
		visible = false
		
		audio_player.play()
		
		Globals.relics[0] = true
