extends Node3D

@export var text: String = "placeholder"

@onready var sign_label: Label = $SubViewport/CenterContainer/Label
@onready var control: HBoxContainer = $SubViewport/CenterContainer/HBoxContainer


func _ready() -> void:
	sign_label.text = text
	sign_label.visible = false
	control.visible = false

func _process(_delta: float) -> void:
	if !control.visible:
		return
	
	if Input.is_action_just_pressed("attack"):
		control.visible = false
		sign_label.visible = true


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		control.visible = true
		sign_label.visible = false


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name.contains("Player"):
		control.visible = false
		sign_label.visible = false
