extends Control


@onready var shards = $MarginContainer/HBoxContainer/Label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	shards.text = str(Globals.shards)
