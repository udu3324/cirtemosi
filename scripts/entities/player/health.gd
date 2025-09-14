extends Control


func _process(delta: float) -> void:
	$MarginContainer/GridContainer/ProgressBar.value = Globals.health
