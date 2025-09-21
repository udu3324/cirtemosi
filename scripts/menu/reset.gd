extends Control


@onready var exit_button = $MarginContainer/VBoxContainer/VBoxContainer/ExitButton

signal exit_to_start


func _process(_delta: float) -> void:
	if !self.visible:
		return
	
	if Input.is_action_just_pressed("ui_right"):
		get_viewport().gui_get_focus_owner().pressed.emit()

func _on_back_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	emit_signal("exit_to_start")


func _on_button_mouse_entered() -> void:
	Globals.menu_pick_fx_event = -10.0


func _on_visibility_changed() -> void:
	if self.visible:
		exit_button.grab_focus()
