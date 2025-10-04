extends Node3D

@onready var zone = $IslandFight/Area3DSpawn

var started: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		Globals.player_death_event = "floor_death"


func _on_area_3d_trigger_start_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		started = true
		_spawn_enemt()

func _spawn_enemt():
	print_debug("SPAWNed enemt")
	
	var radius = zone.get_child(0).shape.radius
	
	var angle = randf() * TAU
	var r = sqrt(randf()) * radius
	
	var local_pos = Vector3(r * cos(angle), 0, r * sin(angle))
	var world_pos = zone.global_transform.origin + local_pos
	world_pos.y = 1.0
	
	var enemt = preload("res://entities/enemt/enemt.tscn").instantiate()
	enemt.global_transform.origin = world_pos
	
	Globals.root_node_3d.add_child(enemt)
