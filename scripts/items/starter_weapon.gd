extends Node3D

@onready var audio_player = $AudioStreamPlayer3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player" and self.visible:
		print_debug("picking up starter sword")
		self.visible = false
		Globals.equipment[0] = "starter_weapon"
		
		audio_player.play()
