extends Control

@onready var name_input: LineEdit = $CenterContainer/VBoxContainer/LineEdit

@onready var center_container: CenterContainer = $CenterContainer
@onready var button_grid_container: GridContainer = $CenterContainer/VBoxContainer/GridContainer

@onready var button_focus: Button = $CenterContainer/VBoxContainer/GridContainer/Button

func _ready() -> void:
	center_container.visible = false # in case i forget
	
	for button: Button in button_grid_container.get_children():
		button.pressed.connect(_on_key_pressed.bind(button))

func _process(_delta: float) -> void:
	if center_container.visible and get_viewport().gui_get_focus_owner() == null:
		button_focus.grab_focus()

func _on_key_pressed(button: Button):
	var character = button.text
	
	if character == "←":
		if name_input.text.length() > 0:
			name_input.text = name_input.text.substr(0, name_input.text.length() - 1)
	else:
		name_input.text += character
	
	#print("pressed " + character)


func _on_dont_save_pressed() -> void:
	pass # Replace with function body.


func _on_submit_pressed() -> void:
	pass # Replace with function body.
