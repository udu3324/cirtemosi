extends Node

# gui
var startVisible: bool = false
var loadingVisible: bool = false
var resetVisible: bool = false
var arcadeUIVisible: bool = false

var settingsVisible: bool = false

var menu_pick_fx_event = null # default is null, set to float to trigger

var hint_attack_switch_control_event: bool = false

var credits_trigger_enter: bool = false
var credits_trigger_exit: bool = false

var settings_trigger_enter: bool = false
var settings_trigger_exit: bool = false


# player movement
var player_pos: Vector3 = Vector3(0, 0, 0)
var camera_size: float = 5.762

var player_can_move: bool = true
var player_physics_processing: bool = true
var player_is_stunned: bool = false

var player_vignette_event: bool = false
var player_pushback_event: Vector3 = Vector3.ZERO
var player_physics_reset_event: bool = false

var player_level_traverse_event: String = ""
var player_death_event: String = ""
var player_self_destruct_event: bool = false


# player stats
const health_max: float = 100.0

var health: float = 100.0

const stamina_max: float = 80.0
const stamina_usage: float = 0.4
const stamina_usage_stunned: float = 0.8
var stamina_recovery_amount: float = 0.05
var stamina_recovery_time: float = 1.0
var stamina_regeneration: bool = true

var stamina: float = 80.0

var slot_active: int = 1
var equipment = ["", "", ""]

var item_info_dict = {
	"starter_weapon": {
		"range": 1.7, # meters
		"cone": 60, # degrees
		"damage": 20
	}
}


var relics = [false, false, false, false, false, false, false]

var shards: int = 0

# story mode variables - reset when the game resets
var save_point: float = -1.0
# - 4.1
var card_ruins_shown: bool = false
var collected_shard_stack: bool = false

# settings
var screen_relative_movement = true
var easy_mode = false

# between story and arcade mode
var enemt_deaths = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var enemt_death_cleared = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

var zert_deaths = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var zert_death_cleared = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

# global storage
var master_audio: AudioStreamPlayer
var root_node_3d: Node3D

var title_card: Control

var title_crypt: Label
var description_crypt: Label
var title_decrypt: Label

var arcade_title: Label
var arcade_description: Label
var arcade_time: Label

# global funcs
func _get_all_nodes(node) -> Array:
	var nodes = []
	
	for child in node.get_children():
		nodes.append(child)
		nodes += _get_all_nodes(child)
	
	return nodes

func translate_to_interface(text: String) -> String:
	var result = ""
	
	for c in text.to_lower():
		if interface_lang_dict.has(c):
			result += interface_lang_dict[c]
		else:
			result += c
	
	return result

## @brief this function creates disposable audio streams for each fx for the specified audio player node
## @param audioStreamPlayer: the node used
## @param sound: the audiostream through preload()ing a resource
## @param volume_dbs: default is 0.0, can be louder or quieter
## @param pitch: default is 1.0, can be higher or lower pitched
func _play_fx(audioStreamPlayer, sound: AudioStream, volume_dbs: float, pitch: float):
	var player = audioStreamPlayer.duplicate()
	player.stream = sound
	player.volume_db = volume_dbs
	player.pitch_scale = pitch
	
	audioStreamPlayer.get_parent().add_child(player)
	player.play()
	
	player.connect("finished", Callable(player, "queue_free"))


func _show_title_card(title: String, description: String, pre_wait: float):
	
	await get_tree().create_timer(pre_wait).timeout
	
	title_card.modulate.a = 0.0
	title_card.visible = true
	
	title_crypt.text = Globals.translate_to_interface(title)
	description_crypt.text = Globals.translate_to_interface(description)
	title_decrypt.text = "- " + title + " -"
	
	var tween = create_tween()
	tween.tween_property(title_card, "modulate:a", 1.0, 1.0)
	
	await tween.finished
	await get_tree().create_timer(3.0).timeout
	
	tween = create_tween()
	tween.tween_property(title_card, "modulate:a", 0.0, 1.0)
	
	await tween.finished
	
	title_card.visible = false

# =========================================
# WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!
# WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!
# WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!
# WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!
# WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!
# WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!
# WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!
#
#   DO NOT SCROLL DOWN UNLESS IF YOU WANT TO SEE THE DICTIONARY
#   USED FOR SCRAMBLING THE LANGUAGE FOR THE INTERFACE
#   IT IS A SPOILER WARNING IF YOU WANT TO UNSCRABLE IT YOURSELF
#
# WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!
# WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!
# WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!
# WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!
# WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!
# WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!
# WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!WARNING!!!
# =========================================

# interface lang dictionary
var interface_lang_dict = {
	"a": "*",
	"b": "!@",
	"c": "~`",
	"d": "{",
	"e": "%",
	"f": "#",
	"g": ",-",
	"h": "@",
	"i": "*)",
	"j": "`~",
	"k": "-{",
	"l": "-",
	"m": "=",
	"n": "_.",
	"o": "^_",
	"p": ";",
	"q": "'",
	"r": "+",
	"s": "[",
	"t": "{",
	"u": "$~",
	"v": "&.",
	"w": "><",
	"x": "~[",
	"y": ",.",
	"z": "}",
}
