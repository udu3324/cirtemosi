extends Node

# gui
var startVisible: bool = false
var loadingVisible: bool = false

# player movement
var player_pos: Vector3 = Vector3(0, 0, 0)

var player_can_move: bool = true
var player_is_stunned: bool = false

var player_pushback_event: Vector3 = Vector3.ZERO
var player_physics_reset_event: bool = false

var player_level_traverse_event: String = ""

# player stats
var health_max: float = 100.0

var health: float = 100.0

var stamina_max: float = 80.0
var stamina_usage: float = 0.7
var stamina_recovery: float = 0.05
var stamina_regeneration: bool = true

var stamina: float = 80.0
