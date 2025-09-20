extends Node

# gui
var startVisible: bool = false
var loadingVisible: bool = false
var resetVisible: bool = false

var settingsVisible: bool = false

var menu_pick_fx_event: bool = false

var hint_attack_switch_control_event: bool = false

var credits_trigger_enter: bool = false
var credits_trigger_exit: bool = false

var settings_trigger_enter: bool = false
var settings_trigger_exit: bool = false


# player movement
var player_pos: Vector3 = Vector3(0, 0, 0)

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
const stamina_usage: float = 0.7
var stamina_recovery_amount: float = 0.05
var stamina_recovery_time: float = 1.0
var stamina_regeneration: bool = true

var stamina: float = 80.0

var slot_active: int = 1
var equipment = ["", "", ""]

var relics = [false, false, false, false, false, false, false]

# settings
var screen_relative_movement = true
var easy_mode = false


# global storage
var root_node_3d: Node3D

# global funcs
func _get_all_nodes(node) -> Array:
	var nodes = []
	
	for child in node.get_children():
		nodes.append(child)
		nodes += _get_all_nodes(child)
	
	return nodes

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
