extends Control

signal settings_open
signal exit_to_start

var loaded = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	_handle_input()

func _handle_input():
	# if user pressed exit key, toggle pause menu
	if Input.is_action_just_pressed("ui_cancel") and !Globals.startVisible:
		self.visible = !self.is_visible_in_tree();

# pause the game if the node detects that its visibility changed
func _on_visibility_changed() -> void:
	# this func is called before it even is loaded in the tree bruh
	if !is_inside_tree():
		return
	
	var visible = self.is_visible_in_tree()
	
	get_tree().paused = visible

func _on_button_unpause_pressed() -> void:
	print_debug("pressing unpause button")
	hide()

func _on_settings_button_pressed() -> void:
	emit_signal("settings_open")

func _on_exit_button_pressed() -> void:
	emit_signal("exit_to_start")
