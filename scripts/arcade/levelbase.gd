extends Node3D

@onready var zone = $IslandFight/Area3DSpawn
@onready var bridge = $Bridge

var on_wave: int = 0
var time_elapsed: float = 0.0
var started: bool = false

var wave_enemt_deaths: int = 0
var wave_enemt_goal: int = 0
var wave_enemt_spawn_time: float = 0

var wave_zert_deaths: int = 0
var wave_zert_goal: int = 0
var wave_zert_spawn_time: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# handle count up time
	if started:
		time_elapsed += delta
		Globals.arcade_time.text = _format_time(time_elapsed)
	
	# handle a enemt death
	if Globals.enemt_deaths[0] == 1:
		Globals.enemt_deaths[0] = 0
		
		wave_enemt_deaths += 1
		Globals.arcade_description.text = "enemt " + str(wave_enemt_deaths) + "/" + str(wave_enemt_goal)
		
		if wave_enemt_deaths == wave_enemt_goal:
			Globals.arcade_title.text = "cleared " + Globals.arcade_title.text + "!"
			
			await get_tree().create_timer(2).timeout
			Globals.arcade_title.text = ""
			await get_tree().create_timer(0.4).timeout
			Globals.health = Globals.health_max
			await get_tree().create_timer(0.8).timeout
			
			if on_wave == 1:
				_new_wave("2", 1, 0.5, 0, 0)
			elif on_wave == 2:
				_new_wave("3", 2, 0, 0, 0)
			elif on_wave == 3:
				pass # todo
			
			return
		
		await get_tree().create_timer(wave_enemt_spawn_time).timeout
		
		_spawn_enemt()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		Globals.player_death_event = "floor_death"
		started = false
		
		# todo send and reset
	
	# todo handle enemt death


func _on_area_3d_trigger_start_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and !started:
		started = true
		
		bridge.queue_free()
		
		_new_wave("1", 1, 1.5, 0, 0)

func _new_wave(wave_name: String, enemt_goal: int, enemt_spawn_time: float, zert_goal: int, zert_spawn_time: float):
	on_wave += 1
	
	wave_enemt_deaths = 0
	wave_zert_deaths = 0
	
	wave_enemt_spawn_time = enemt_spawn_time
	wave_zert_spawn_time = zert_spawn_time
	
	wave_enemt_goal = enemt_goal
	wave_zert_goal = zert_goal
	
	Globals.arcade_title.text = ""
	Globals.arcade_description.text = ""
	
	if enemt_goal != 0:
		Globals.arcade_description.text += "enemt " + str(wave_enemt_deaths) + "/" + str(wave_enemt_goal) + "\n"
	
	if zert_goal != 0:
		Globals.arcade_description.text += "zert " + str(wave_zert_deaths) + "/" + str(wave_zert_goal) + "\n"
		
	Globals.arcade_title.text = "wave " + wave_name
	
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
	enemt.rng_shard_drops = false
	
	Globals.root_node_3d.add_child(enemt)

# ty https://forum.godotengine.org/t/formatting-a-timer/6482/2
func _format_time(time_elapsed: float) -> String: 
	var minutes = time_elapsed / 60
	var seconds = fmod(time_elapsed, 60)
	var milliseconds = fmod(time_elapsed, 1) * 100
	return "%01d:%02d:%02d" % [minutes, seconds, milliseconds]
