extends Control


func _process(_delta: float) -> void:
	$MarginContainer/GridContainer/ProgressBar.value = Globals.health
