extends Node3D

@export_range (0, 24) var array_death_log: int = 0
@export var ignore_player: bool = false
@export var despawns: bool = true
@export var drops_relic_1: bool = false
@export var drops_shards: bool = true
@export var rng_shard_drops: bool = true
@export_range (1, 100) var rand_shard_range: int = 5

func _ready():
	get_child(1).array_death_log = array_death_log
	get_child(1).ignore_player = ignore_player
	get_child(1).despawns = despawns
	get_child(1).drops_relic_1 = drops_relic_1
	get_child(1).drops_shards = drops_shards
	get_child(1).rng_shard_drops = rng_shard_drops
	get_child(1).rand_shard_range = rand_shard_range
