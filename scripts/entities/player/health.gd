extends Control

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	$MarginContainer/GridContainer/ProgressBar.value = Globals.health
