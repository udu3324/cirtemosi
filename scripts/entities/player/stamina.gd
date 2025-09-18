extends Control


func _process(_delta: float) -> void:
	$MarginContainer/GridContainer/ProgressBar.value = Globals.stamina
	
	# regenerate sprint over time, but also punish player for holding down sprint
	if !Input.is_action_pressed("sprint") and Globals.stamina < Globals.stamina_max and Globals.stamina_regeneration:
		Globals.stamina = Globals.stamina + Globals.stamina_recovery_amount
		# print_debug("stamina is now", Globals.stamina)
	
	# punish player for after using stamina
	if Input.is_action_just_released("sprint"):
		Globals.stamina_regeneration = false
		await get_tree().create_timer(Globals.stamina_recovery_time).timeout
		Globals.stamina_regeneration = true
