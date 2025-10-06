extends Node3D

@onready var audio_player = $AudioStreamPlayer3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and self.visible:
		print_debug("picking up starter sword")
		self.visible = false
		Globals.equipment[0] = "starter_weapon"
		
		audio_player.play()
		
		Globals.hint_attack_switch_control_event = true
		
		#self.queue_free()
