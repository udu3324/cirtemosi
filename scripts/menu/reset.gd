extends Control

signal exit_to_start


func _on_back_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	emit_signal("exit_to_start")


func _on_button_mouse_entered() -> void:
	Globals.menu_pick_fx_event = true
