extends RigidBody3D

@onready var audio_player = $AudioStreamPlayer3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and self.visible:
		print_debug("picked up relic 2")
		visible = false
		
		audio_player.play()
		
		Globals.relics[1] = true
		
		self.collision_layer = 0
		self.collision_mask = 0
		
		#self.queue_free()
		audio_player.finished.connect(queue_free)
