extends Node3D

@onready var shard_stack: Node3D = $Upper/HiddenStackOfShards
@onready var bow: Node3D = $Bow
@onready var spawners: Node3D = $Spawners

func _ready() -> void:
	if Globals.collected_shard_stack:
		remove_child(shard_stack)
	if Globals.equipment[1] == "bow":
		remove_child(bow)

func _process(_delta: float) -> void:
	#DebugDraw3D.draw_sphere(_get_random_spawn_point(), 0.01, Color.AQUA)
	
	if Globals.enemt_deaths[1] >= 2:
		Globals.enemt_deaths[1] = 0
		
		# replace the two that died previously
		for i in range(2):
			var world_pos: Vector3 = _get_random_spawn_point()
			
			var enemt = preload("res://entities/enemt/enemt.tscn").instantiate()
			enemt.name = "Enemt" + str(randi())
			enemt.global_transform.origin = world_pos
			enemt.array_death_log = 1
	
			Globals.root_node_3d.add_child(enemt)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		print_debug("entering to level 3")
		Globals.player_level_traverse_event = "4.1->3"


func _on_area_3d_2_title_card_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and !Globals.card_ruins_shown:
		Globals._show_title_card(tr("Ruins"), "Future Civilization", 0.8)
		Globals.card_ruins_shown = true
	
	if body.name.contains("Player"):
		Globals.save_point = 4.1


func _on_area_3d_collected_shard_stack_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		Globals.collected_shard_stack = true

func _get_random_spawn_point() -> Vector3:
	var randomArea3D = randi_range(0, spawners.get_child_count() - 1)
	var zone: Area3D = spawners.get_child(randomArea3D)
	
	var radius = zone.get_child(0).shape.radius
	
	var angle = randf() * TAU
	var r = sqrt(randf()) * radius
	
	var local_pos = Vector3(r * cos(angle), 0, r * sin(angle))
	var world_pos = zone.global_transform.origin + local_pos
	world_pos.y = global_transform.origin.y
	
	return world_pos
