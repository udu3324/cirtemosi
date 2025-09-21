extends Control

signal level_1

@onready var playButton = $MarginContainer/VBoxContainer2/MarginContainer/VBoxContainer/PlayButton
@onready var settingsButton = $MarginContainer/VBoxContainer2/MarginContainer/VBoxContainer/SettingsButton
@onready var creditsButton = $MarginContainer/VBoxContainer2/MarginContainer/VBoxContainer/CreditsButton

@onready var currently_selected = playButton

func _ready() -> void:
	playButton.grab_focus()

func _on_button_start_pressed() -> void:
	hide()
	emit_signal("level_1")
	Globals.menu_pick_fx_event = 0.0

func _on_button_settings_pressed() -> void:
	Globals.menu_pick_fx_event = 0.0
	Globals.settings_trigger_enter = true

func _on_credits_button_pressed() -> void:
	Globals.menu_pick_fx_event = 0.0
	Globals.credits_trigger_enter = true

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
		Globals.menu_pick_fx_event = -10.0
		
		# for some reason, i have to store the node instead of grabbing it in realtime
		currently_selected = get_viewport().gui_get_focus_owner()
	
	if Input.is_action_just_pressed("ui_right"):
		#print_debug("pressed it")
		currently_selected.pressed.emit()
	
	if get_viewport().gui_get_focus_owner() == null:
		playButton.grab_focus()

func _on_button_mouse_entered() -> void:
	Globals.menu_pick_fx_event = -10.0
