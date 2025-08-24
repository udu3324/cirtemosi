extends Control

signal level_1

func _on_button_start_pressed() -> void:
	hide()
	emit_signal("level_1")

func _on_button_settings_pressed() -> void:
	pass # Replace with function body.
