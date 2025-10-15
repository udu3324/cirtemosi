extends Control

@onready var relic_1_silhouette = $MarginContainer/HBoxContainer/CenterContainer
@onready var relic_1 = $MarginContainer/HBoxContainer/Relic1
@onready var relic_2_silhouette = $MarginContainer/HBoxContainer/CenterContainer2
@onready var relic_2 = $MarginContainer/HBoxContainer/Relic2
@onready var relic_3_silhouette = $MarginContainer/HBoxContainer/CenterContainer3
@onready var relic_3 = $MarginContainer/HBoxContainer/Relic3
@onready var relic_4_silhouette = $MarginContainer/HBoxContainer/CenterContainer4
@onready var relic_4 = $MarginContainer/HBoxContainer/Relic4
@onready var relic_5_silhouette = $MarginContainer/HBoxContainer/CenterContainer5
@onready var relic_5 = $MarginContainer/HBoxContainer/Relic5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if Globals.relics[0] and !relic_1.visible:
		relic_1_silhouette.visible = false
		relic_1.visible = true
	elif !Globals.relics[0] and relic_1.visible:
		relic_1_silhouette.visible = true
		relic_1.visible = false
	
	if Globals.relics[1] and !relic_2.visible:
		relic_2_silhouette.visible = false
		relic_2.visible = true
	elif !Globals.relics[1] and relic_2.visible:
		relic_2_silhouette.visible = true
		relic_2.visible = false
	
	if Globals.relics[2] and !relic_3.visible:
		relic_3_silhouette.visible = false
		relic_3.visible = true
	elif !Globals.relics[2] and relic_3.visible:
		relic_3_silhouette.visible = true
		relic_3.visible = false
	
	if Globals.relics[3] and !relic_4.visible:
		relic_4_silhouette.visible = false
		relic_4.visible = true
	elif !Globals.relics[3] and relic_4.visible:
		relic_4_silhouette.visible = true
		relic_4.visible = false
	
	if Globals.relics[4] and !relic_5.visible:
		relic_5_silhouette.visible = false
		relic_5.visible = true
	elif !Globals.relics[4] and relic_5.visible:
		relic_5_silhouette.visible = true
		relic_5.visible = false
