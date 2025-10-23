@tool
extends Node3D

@export var relic_outline: Color = Color(0.518, 0.075, 0.122)
@export_range(1, 5) var relic: int = 1
@export var relic_hidden: CompressedTexture2D = preload("res://assets/relics/relic_1_hidden_icon.png")
@export var relic_shown: CompressedTexture2D = preload("res://assets/relics/relic_1_icon.png")

@onready var relic_tex: TextureRect = $SubViewport/CenterContainer/HBoxContainer/TextureRect2

@onready var container: CenterContainer = $SubViewport/CenterContainer

var handle_input: bool = false
var inserted: bool = false

func _ready() -> void:
	container.visible = false
	
	relic_tex.material = relic_tex.material.duplicate()
	
	relic_tex.material.set_shader_parameter("line_color", relic_outline)
	
	relic_tex.texture = relic_hidden
	
	# if player has relic, replace img with shown relic
	if Globals.relics[relic - 1]:
		relic_tex.texture = relic_shown
		pass
	
	# in case if scene has been reloaded
	if Globals.inserted_relic[relic - 1]:
		inserted = true

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		container.visible = true
		return

	if !handle_input:
		return
	
	if Input.is_action_just_pressed("attack"):
		
		# player does not have relic
		if !Globals.relics[relic - 1]:
			return
		
		print("inserted relic ", relic)
		
		container.visible = false
		handle_input = false
		inserted = true
		Globals.inserted_relic[relic - 1] = true


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and !inserted:
		container.visible = true
		handle_input = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name.contains("Player"):
		container.visible = false
		handle_input = false
