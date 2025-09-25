extends Node3D

@onready var model = $Node3D
@onready var screen = $Node3D/Screen
@onready var audio_player = $Node3D/AudioStreamPlayer3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_outer_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		pass

func _on_outer_area_3d_body_exited(body: Node3D) -> void:
	if body.name.contains("Player"):
		pass


func _on_inner_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		pass

func _on_inner_area_3d_body_exited(body: Node3D) -> void:
	if body.name.contains("Player"):
		pass
