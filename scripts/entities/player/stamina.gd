extends Control

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	$MarginContainer/GridContainer/ProgressBar.value = Globals.stamina
	
	if !Input.is_action_pressed("sprint") and Globals.stamina < Globals.stamina_max:
		Globals.stamina = Globals.stamina + Globals.stamina_recovery
		# print_debug("stamina is now", Globals.stamina)
