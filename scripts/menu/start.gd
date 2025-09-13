extends Control

signal level_1

@onready var playButton = $MarginContainer/VBoxContainer2/VBoxContainer/PlayButton
@onready var settingsButton = $MarginContainer/VBoxContainer2/VBoxContainer/SettingsButton
@onready var creditsButton = $MarginContainer/VBoxContainer2/VBoxContainer/CreditsButton

@onready var audio_menu_select = $AudioStreamPlayer2D

func _ready() -> void:
	playButton.grab_focus()

func _on_button_start_pressed() -> void:
	hide()
	emit_signal("level_1")
	audio_menu_select.play()

func _on_button_settings_pressed() -> void:
	audio_menu_select.play()
	#todo

func _on_credits_button_pressed() -> void:
	audio_menu_select.play()
	#todo

func _process(_delta: float) -> void:
	_handle_input()
	# $MarginContainer2/Panel.add_theme_stylebox_override("", style)

func _handle_input():
	if !visible:
		return
	
	#todo arrow that goes up/down
	var input = Input.get_axis("ui_up", "ui_down")
	
	if input > 0.5:
		pass
	
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
		audio_menu_select.play()
