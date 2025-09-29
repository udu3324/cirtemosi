extends Control


@onready var window = $CenterContainer/MarginContainer

@onready var screen_relative_movement_btn = $CenterContainer/MarginContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/ScreenRelativeMovement
@onready var easy_mode_btn = $CenterContainer/MarginContainer/MarginContainer/VBoxContainer/VBoxContainer2/HBoxContainer/EasyMode
@onready var volume_slider = $CenterContainer/MarginContainer/MarginContainer/VBoxContainer/VBoxContainer3/HBoxContainer/MasterVolume

var mouse_is_inside: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# set default settings from globals
	screen_relative_movement_btn.button_pressed = Globals.screen_relative_movement
	easy_mode_btn.button_pressed = Globals.easy_mode
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	Globals.settingsVisible = visible
	
	if Globals.settings_trigger_enter:
		_on_settings_show()
		Globals.settings_trigger_enter = false
	
	if Globals.settings_trigger_exit:
		_on_settings_hide()
		Globals.settings_trigger_exit = false
	
	_check_for_mouse()
	
	if Input.is_action_pressed("attack") and self.visible and !mouse_is_inside:
		
		Globals.settings_trigger_exit = true
		
	elif Input.is_action_just_pressed("just_l_key") and self.visible:
		# this is if the user pressed the key while inside of the box which is ok
		Globals.settings_trigger_exit = true
	
	if !self.visible:
		return
	
	if get_viewport().gui_get_focus_owner() is HSlider:
		return
	
	if Input.is_action_just_pressed("switch"):
		var node = get_viewport().gui_get_focus_owner()
		node.button_pressed = !node.button_pressed

func _on_settings_show():
	print_debug("showing settings")
	visible = true
	
	screen_relative_movement_btn.grab_focus()

func _on_settings_hide():
	print_debug("hiding settings")
	visible = false

# godot's mouse_entered() is bugged and breaks for children inside of the main node...
# https://github.com/godotengine/godot-proposals/issues/3956#issuecomment-1250120585
func _check_for_mouse():
	var rect = window.get_global_rect()
	var mouse_pos = get_global_mouse_position()
	
	mouse_is_inside = rect.has_point(mouse_pos)


func _on_screen_relative_movement_toggled(toggled_on: bool) -> void:
	Globals.screen_relative_movement = toggled_on


func _on_easy_mode_toggled(toggled_on: bool) -> void:
	Globals.easy_mode = toggled_on
	
	Globals.stamina_recovery_amount = 0.5 if Globals.easy_mode else 0.05
	Globals.stamina_recovery_time = 0.5 if Globals.easy_mode else 1.0

func _on_master_volume_value_changed(value: float) -> void:
	#print_debug("volume changed to ", volume_slider.value - 15)
	AudioServer.set_bus_volume_db(0, volume_slider.value - 15)
