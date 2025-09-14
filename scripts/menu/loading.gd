extends Control

@onready var label = $MarginContainer2/Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print_debug("adding dot11111s")
	var text_animation := Timer.new()
	text_animation.wait_time = 0.5
	text_animation.one_shot = false
	text_animation.connect("timeout", _dots)
	
	add_child(text_animation)
	
	text_animation.start()


var dots_number = 0
func _dots():
	#print_debug("adding dots")
	dots_number += 1
	var count = dots_number % 3 + 1
	label.text = "loading" + ".".repeat(count)
