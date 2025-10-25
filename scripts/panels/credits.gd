extends Control

@onready var creditsScroll = $CenterContainer

signal exit_to_start


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("attack") and self.visible:
		Globals.credits_trigger_exit = true
	
	if Globals.credits_trigger_enter:
		_on_credits_show()
		Globals.credits_trigger_enter = false
	
	if Globals.credits_trigger_exit:
		_on_credits_hide()
		Globals.credits_trigger_exit = false

var credits_opacity
var credits_audio_fade
var credits_scroll

func _on_credits_show():
	if visible:
		return
	
	print_debug("showing credits")
	
	visible = true
	
	creditsScroll.modulate.a = 0.0
	creditsScroll.position.y = DisplayServer.window_get_size().y
	
	credits_opacity = create_tween()
	credits_opacity.tween_property(creditsScroll, "modulate:a", 1.0, 3)
	
	credits_audio_fade = create_tween()
	#credits_audio_fade.tween_property(masterAudio, "volume_db", -10.0, 2)
	
	credits_scroll = create_tween()
	credits_scroll.tween_property(creditsScroll, "position:y", -creditsScroll.size.y, 40)
	
	await credits_scroll.finished
	await get_tree().create_timer(1).timeout
	
	_on_credits_hide()

func _on_credits_hide():
	creditsScroll.modulate.a = 0.0
	#masterAudio.volume_db = -5.0
	
	visible = false
	
	credits_opacity.kill()
	credits_scroll.kill()
	credits_audio_fade.kill()
	
	var next = Globals.root_node_3d.find_child("Level4_4", true, false)
	if next != null:
		print("exiting")
		emit_signal("exit_to_start")
