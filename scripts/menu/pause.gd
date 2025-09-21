extends Control


@onready var backButton = $MarginContainer/VBoxContainer/VBoxContainer/BackButton
@onready var settingsButton = $MarginContainer/VBoxContainer/VBoxContainer/SettingsButton
@onready var exitButton = $MarginContainer/VBoxContainer/VBoxContainer/ExitButton

signal exit_to_start

var loaded = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	_handle_input()
	
	if !visible:
		return
	
	if get_viewport().gui_get_focus_owner() == null:
		print_debug("grabbing focus for pause")
		backButton.grab_focus()
	
	if Input.is_action_just_pressed("ui_right"):
		print_debug("pressed")
		get_viewport().gui_get_focus_owner().pressed.emit()

func _handle_input():
	# if user pressed exit key, toggle pause menu
	if Input.is_action_just_pressed("ui_cancel") and !Globals.startVisible and !Globals.loadingVisible and !Globals.resetVisible and !Globals.settingsVisible:
		self.visible = !self.is_visible_in_tree();
		
		# punish player for pausing
		if !self.visible:
			Globals.stamina_regeneration = false
			await get_tree().create_timer(Globals.stamina_recovery_time).timeout
			Globals.stamina_regeneration = true

# pause the game if the node detects that its visibility changed
func _on_visibility_changed() -> void:
	# this func is called before it even is loaded in the tree bruh
	if !is_inside_tree():
		return
	
	get_tree().paused = is_visible_in_tree()

func _on_button_unpause_pressed() -> void:
	print_debug("pressing unpause button")
	hide()

func _on_settings_button_pressed() -> void:
	Globals.settings_trigger_enter = 0.0

func _on_exit_button_pressed() -> void:
	emit_signal("exit_to_start")


func _on_button_mouse_entered() -> void:
	Globals.menu_pick_fx_event = -10.0
