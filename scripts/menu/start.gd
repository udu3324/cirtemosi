extends Control

signal level_1

@onready var playButton = $MarginContainer/VBoxContainer2/VBoxContainer/PlayButton
@onready var settingsButton = $MarginContainer/VBoxContainer2/VBoxContainer/SettingsButton
@onready var creditsButton = $MarginContainer/VBoxContainer2/VBoxContainer/CreditsButton

func _ready() -> void:
	playButton.grab_focus()

func _on_button_start_pressed() -> void:
	hide()
	emit_signal("level_1")

func _on_button_settings_pressed() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	_handle_input()

func _handle_input():
	#todo arrow that goes up/down
	var input = Input.get_axis("ui_up", "ui_down")
	
	if input > 0.5:
		pass
