extends Control

@onready var glint1 = $MarginContainer/HBoxContainer/Slot1/SelectionGlint
@onready var glint2 = $MarginContainer/HBoxContainer/Slot2/SelectionGlint
@onready var glint3 = $MarginContainer/HBoxContainer/Slot3/SelectionGlint

@onready var starter_weapon = $MarginContainer/HBoxContainer/Slot1/Sword

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# hide all glints
	glint1.visible = false
	glint2.visible = false
	glint3.visible = false
	
	# set a specific glint
	if Globals.slot_active == 1:
		glint1.visible = true
	elif Globals.slot_active == 2:
		glint2.visible = true
	elif Globals.slot_active == 3:
		glint3.visible = true
	
	# switch glint on action
	if Input.is_action_just_pressed("switch"):
		if Globals.slot_active < 3:
			Globals.slot_active += 1
		else:
			Globals.slot_active = 1
	
	# unhide weapons
	if Globals.equipment[0] == "starter_weapon":
		starter_weapon.visible = true
