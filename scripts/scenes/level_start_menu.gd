extends Node3D

@onready var light_rot = $Lights

var tween

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
		
		if tween != null:
			tween.kill()
		
		var rot = randi_range(-35, 35)
		#var time = randf_range(0.3, 2)
		
		tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(light_rot, "rotation:y", deg_to_rad(rot), 0.1)
