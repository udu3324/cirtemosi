@tool
extends Node3D

@export_range (0, 24) var array_death_log: int = 0
@export var ignore_player: bool = false
@export var despawns: bool = true
@export var drops_relic_3: bool = false
@export var drops_shards: bool = true
@export var rng_shard_drops: bool = true
@export_range (1, 100) var rand_shard_range: int = 20
@export var line_path_length: float = 3
@export_range (0, 180) var line_path_angle: int = 45

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_child(1).array_death_log = array_death_log
	get_child(1).ignore_player = ignore_player
	get_child(1).despawns = despawns
	get_child(1).drops_relic_3 = drops_relic_3
	get_child(1).drops_shards = drops_shards
	get_child(1).rng_shard_drops = rng_shard_drops
	get_child(1).rand_shard_range = rand_shard_range
	get_child(1).line_path_length = line_path_length
	get_child(1).line_path_angle = line_path_angle
	
	get_child(1)._regen_points()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		var forward_dir = -global_transform.basis.z.normalized()
		var backward_dir = global_transform.basis.z.normalized()
	
		var angle_offset = deg_to_rad(line_path_angle)
	
		var rotated_forward = (Basis(Vector3.UP, angle_offset) * forward_dir).normalized()
		var rotated_backward = (Basis(Vector3.UP, angle_offset) * backward_dir).normalized()
	
		var start = global_position + rotated_forward * line_path_length
		var end = global_position + rotated_backward * line_path_length
		
		DebugDraw3D.draw_line(start, end, Color(1.0, 0.0, 0.0, 1.0))
