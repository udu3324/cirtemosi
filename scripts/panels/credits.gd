extends Control

signal credits_exit

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("attack") and self.visible:
		Globals.credits_trigger_exit = true
