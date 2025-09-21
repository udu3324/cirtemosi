extends RigidBody3D

@onready var audio_player = $AudioStreamPlayer3D

func _ready() -> void:
	self.rotation = Vector3(randf_range(0, TAU), randf_range(0, TAU), randf_range(0, TAU))

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and self.visible:
		print_debug("picking up a shard")
		self.visible = false
		
		Globals.shards += 1
		
		self.collision_layer = 0
		self.collision_mask = 0
		
		audio_player.play()
		
		#self.queue_free()
		audio_player.finished.connect(queue_free)
