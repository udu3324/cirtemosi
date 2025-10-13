extends Node3D

@onready var audio_player = $AudioStreamPlayer3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and self.visible:
		print_debug("picking up bow")
		self.visible = false
		Globals.equipment[1] = "bow"
		Globals.slot_active = 2
		
		audio_player.play()
		
		Globals.hint_attack_switch_control_event = true
		
		#self.queue_free()
