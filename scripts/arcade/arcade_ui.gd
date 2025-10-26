extends Control

@onready var name_input: LineEdit = $MarginContainer4/CenterContainer/VBoxContainer/LineEdit

@onready var center_container: CenterContainer = $MarginContainer4/CenterContainer
@onready var button_grid_container: GridContainer = $MarginContainer4/CenterContainer/VBoxContainer/GridContainer

@onready var button_focus: Button = $MarginContainer4/CenterContainer/VBoxContainer/GridContainer/Button

@onready var key_hints: MarginContainer = $MarginContainer4/MarginContainer3

signal exit_to_start

var regex = RegEx.new()

func _ready() -> void:
	regex.compile("[^a-z0-9_]+")
	
	name_input.text = Globals.arcade_name
	
	center_container.visible = false # in case i forget
	
	for button: Button in button_grid_container.get_children():
		button.pressed.connect(_on_key_pressed.bind(button))

func _process(_delta: float) -> void:
	if center_container.visible and get_viewport().gui_get_focus_owner() == null:
		button_focus.grab_focus()
	
	# show hints
	if center_container.visible and !key_hints.visible:
		key_hints.visible = true
	elif !center_container.visible and key_hints.visible:
		key_hints.visible = false
	
	if get_viewport().gui_get_focus_owner() != null and center_container.visible:
		if Input.is_action_just_pressed("just_l_key"):
			get_viewport().gui_get_focus_owner().pressed.emit()

func _on_key_pressed(button: Button):
	var character = button.text
	
	if character == "←":
		if name_input.text.length() > 0:
			name_input.text = name_input.text.substr(0, name_input.text.length() - 1)
	else:
		name_input.text += character
	
	#print("pressed " + character)
	Globals.arcade_name = name_input.text


func _on_dont_save_pressed() -> void:
	emit_signal("exit_to_start")


func _on_submit_pressed() -> void:
	#var new_entry = {
	#	"player_name": str(randi()),
	#	"wave": Globals.arcade_wave,
	#	"time": Globals.arcade_timef,
	#	"shards": Globals.shards,
	#	"easy_mode": Globals.easy_mode
	#}
	
	if Globals.arcade_name.length() < 3:
		return
	
	# make sure the player actually tries to get through one wave
	DB.submit_score(Globals.arcade_name, Globals.arcade_timef, Globals.arcade_wave, Globals.shards, Globals.easy_mode)
	print("saving data of ", Globals.arcade_name, Globals.arcade_timef, Globals.arcade_wave, Globals.shards, Globals.easy_mode)
	
	emit_signal("exit_to_start")


func _on_line_edit_text_changed(new_text: String) -> void:
	if regex.search(new_text):
		var index = name_input.caret_column
		
		name_input.text = regex.sub(new_text, "", true)
		name_input.caret_column = index - 1
	
	Globals.arcade_name = name_input.text
