extends Node3D

@onready var leaderboard_label: Label = $SubViewport/CenterContainer/VBoxContainer/Label

@onready var zone = $IslandFight/Area3DSpawn
@onready var bridge = $Bridge

@onready var arcade = preload("res://assets/audio/soundtrack/cirtemosi-arcade.ogg")

@onready var island_1 = $Islands/IslandSmaller
@onready var island_2 = $Islands/IslandSmaller2
@onready var island_3 = $Islands/IslandSmaller3
@onready var island_4 = $Islands/IslandSmaller4

@onready var island_1_spawnpoint = $Islands/IslandSmaller/Spawn
@onready var island_2_spawnpoint = $Islands/IslandSmaller2/Spawn
@onready var island_3_spawnpoint = $Islands/IslandSmaller3/Spawn
@onready var island_4_spawnpoint = $Islands/IslandSmaller4/Spawn

@onready var waves = {
	1: { # spawn 4 enemts all spaced out
		"subsequent": true,
		"enemts": 3,
		"enemt_delay": 0.5,
		"zerts": 0,
		"zert_delay": 0,
		"weapon_damage": 20
	},
	2: { # spawn 2 enemts at the same time
		"subsequent": false,
		"enemts": 2,
		"enemt_delay": 0,
		"zerts": 0,
		"zert_delay": 0,
		"weapon_damage": 25
	},
	3: { # spawn 8 enemts all spaced out but fast
		"subsequent": false,
		"enemts": 8,
		"enemt_delay": 3.0,
		"zerts": 0,
		"zert_delay": 0,
		"weapon_damage": 50
	},
	4: { # spawn 4 enemts all at once with a delay
		"subsequent": false,
		"enemts": 4,
		"enemt_delay": 0.0,
		"zerts": 0,
		"zert_delay": 0,
		"weapon_damage": 25
	},
	5: { # spawn a zert
		"subsequent": false,
		"enemts": 0,
		"enemt_delay": 0.0,
		"zerts": 1,
		"zert_delay": 0,
		"weapon_damage": 25
	},
	6: { # spawn a zert and enemts
		"subsequent": false,
		"enemts": 3,
		"enemt_delay": 1.0,
		"zerts": 2,
		"zert_delay": 0,
		"weapon_damage": 25
	},
	7: { # spawn a zert and enemts but more
		"subsequent": false,
		"enemts": 1,
		"enemt_delay": 0.0,
		"zerts": 4,
		"zert_delay": 0,
		"weapon_damage": 25
	},
	8: { # spawn everything
		"subsequent": false,
		"enemts": 4,
		"enemt_delay": 0.0,
		"zerts": 4,
		"zert_delay": 0,
		"weapon_damage": 50
	},
}

var leaderboard_data

var on_wave: int = 0
var time_elapsed: float = 0.0
var started: bool = false
var stop_timer: bool = false

var wave_enemt_deaths: int = 0
var wave_zert_deaths: int = 0

var island_populated = [false, false, false, false]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# load the leaderboard
	DB.leaderboard_request_completed.connect(_on_leaderboard_loaded)
	DB.fetch_top(16)
	
	island_1.visible = false
	island_2.visible = false
	island_3.visible = false
	island_4.visible = false
	
	island_1.global_position.y = 10.0
	island_2.global_position.y = 10.0
	island_3.global_position.y = 10.0
	island_4.global_position.y = 10.0

func _on_leaderboard_loaded(data) -> void:
	
	# handle strange data in case? idk lol
	if typeof(data) == TYPE_DICTIONARY and data.has("leaderboard"):
		leaderboard_data = data["leaderboard"]
	elif typeof(data) == TYPE_ARRAY:
		leaderboard_data = data
	else:
		leaderboard_data = []
	
	leaderboard_label.text = tr("wave") + " | " + tr("time") + " | " + tr("player") + " | " + tr("shards") + " \n"
	
	for score in data:
		var player_name = score.player_name
		var wave = score.wave
		var time = _format_time(score.time)
		var shards = score.shards
		var easy_mode = score.easy_mode
		
		#leaderboard_label.text += str(count) + " - " + player_name + " | wave " + str(wave) + " | " + time + " | " + str(shards) +  " shards"
		leaderboard_label.text += String.num_int64(wave) + " | " + time + " - " + player_name + " - " + String.num_int64(shards) + tr(" shards")
		
		if easy_mode:
			leaderboard_label.text += " (easymode)"
		
		leaderboard_label.text += "\n"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# handle count up time
	if started and !stop_timer:
		time_elapsed += delta
		Globals.arcade_timef = time_elapsed
		Globals.arcade_time.text = _format_time(time_elapsed)
	
	if on_wave == 0:
		return
	
	# handle goals
	if waves[on_wave]["enemts"] == wave_enemt_deaths and waves[on_wave]["zerts"] == wave_zert_deaths:
		
		# i hate my life as well as asynchronous code
		wave_enemt_deaths = 0
		wave_zert_deaths = 0
	
		Globals.arcade_title.text = tr("cleared!")
		
		await get_tree().create_timer(2).timeout
		Globals.arcade_title.text = ""
		await get_tree().create_timer(0.4).timeout
		Globals.health = Globals.health_max
		await get_tree().create_timer(0.8).timeout
		
		if !stop_timer:
			Globals.arcade_wave = on_wave
		
		if on_wave == 1:
			_start_wave(2)
		elif on_wave == 2:
			_start_wave(3)
		elif on_wave == 3:
			_start_wave(4)
		elif on_wave == 4:
			Globals.equipment[1] = "bow"
			Globals.slot_active = 2
			_start_wave(5)
		elif on_wave == 5:
			_start_wave(6)
		elif on_wave == 6:
			_start_wave(7)
		elif on_wave == 7:
			_start_wave(8)
		else:
			stop_timer = true
			Globals.arcade_title.text = tr("finished!")
			#Globals.arcade_description.text = "\n\n\nplease walk off the\nisland for now to\ngo back to the main\nmenu."
			
			await get_tree().create_timer(2.0).timeout
			
			Globals.player_death_event = "arcade_fin_shortcut"
	
	# handle a enemt death
	if Globals.enemt_deaths[0] >= 1: 
		var difference = Globals.enemt_deaths[0]
		Globals.enemt_deaths[0] = 0
		
		wave_enemt_deaths += difference
		_build_description()
		
		if waves[on_wave]["subsequent"] and wave_enemt_deaths != waves[on_wave]["enemts"]:
			await get_tree().create_timer(waves[on_wave]["enemt_delay"]).timeout
			#print("just one 4now")
			_spawn_enemt()
	
	# handle a zert death
	if Globals.zert_deaths[1] >= 1:
		Globals.zert_deaths[1] = 0
		wave_zert_deaths += 1
		island_populated[0] = false
		island_1.visible = false
		island_1.global_position.y = 10.0
		_zert_death_reward()
		_build_description()
	
	if Globals.zert_deaths[2] >= 1:
		Globals.zert_deaths[2] = 0
		wave_zert_deaths += 1
		island_populated[1] = false
		island_2.visible = false
		island_2.global_position.y = 10.0
		_zert_death_reward()
		_build_description()
	
	if Globals.zert_deaths[3] >= 1:
		Globals.zert_deaths[3] = 0
		wave_zert_deaths += 1
		island_populated[2] = false
		island_3.visible = false
		island_3.global_position.y = 10.0
		_zert_death_reward()
		_build_description()
	
	if Globals.zert_deaths[4] >= 1:
		Globals.zert_deaths[4] = 0
		wave_zert_deaths += 1
		island_populated[3] = false
		island_4.visible = false
		island_4.global_position.y = 10.0
		_zert_death_reward()
		_build_description()

func _zert_death_reward():
	Globals.shards += randi_range(3, 10)
	
	var add_health = randi_range(5, 10)
	if (Globals.health + add_health) < Globals.health_max:
		Globals.health += add_health
	
	var add_stamina = randi_range(15, 20)
	if (Globals.stamina + add_stamina) < Globals.stamina_max:
		Globals.stamina += add_stamina

func _build_description():
	Globals.arcade_description.text = ""
	
	if waves[on_wave]["enemts"] >= 1:
		Globals.arcade_description.text += tr("enemt") + " " + str(wave_enemt_deaths) + "/" + str(waves[on_wave]["enemts"]) + "\n"
	
	if waves[on_wave]["zerts"] >= 1:
		Globals.arcade_description.text += tr("zert") + " " + str(wave_zert_deaths) + "/" + str(waves[on_wave]["zerts"]) + "\n"

# floor death area 3d handler - handles death of things
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("Player"):
		Globals.player_death_event = "floor_death"
		started = false
		
		# todo send and reset
	elif body.name.contains("Enemt"):
		body.health = 0.0
		Globals.shards += randi_range(3, 5) # give back player shards
		#print_debug("enemt fell to death")

# trigger start area 3d handler - handles start of arcade mode
func _on_area_3d_trigger_start_body_entered(body: Node3D) -> void:
	if body.name.contains("Player") and !started:
		started = true
		Globals.arcade_started = true
		
		bridge.queue_free()
		
		_start_wave(1)
		
		Globals.master_audio.stream = arcade
		Globals.master_audio.volume_db = -5.0
		Globals.master_audio.play()
		
		var audioFade = create_tween()
		audioFade.tween_property(Globals.master_audio, "volume_db", 0, 2)

# start a new wave
func _start_wave(wave: int):
	on_wave = wave
	
	
	Globals.arcade_title.text = tr("wave") + " " + str(wave)
	Globals.arcade_description.text = ""
	
	# in case if the player forgets to pick up their weapon...
	Globals.equipment[0] = "starter_weapon"
	
	Globals.item_info_dict[Globals.equipment[Globals.slot_active - 1]]["damage"] = waves[on_wave]["weapon_damage"]
	
	#print_debug("new wave spacer")
	if waves[on_wave]["enemts"] != 0:
		Globals.arcade_description.text += tr("enemt") + " " + str(wave_enemt_deaths) + "/" + str(waves[on_wave]["enemts"]) + "\n"
		
		# kickstart wave
		if waves[on_wave]["subsequent"]:
			#print("just one 4now")
			_spawn_enemt()
		else:
			
			for i in range(waves[on_wave]["enemts"]):
				#print("spawning in!!!!")
				var delay = waves[on_wave]["enemt_delay"] * i
				_spawn_enemt_async_internal_func_dont_use(delay)

	if waves[on_wave]["zerts"] != 0:
		Globals.arcade_description.text += tr("zert") + " " + str(wave_zert_deaths) + "/" + str(waves[on_wave]["zerts"]) + "\n"
		
		# kickstart wave
		if waves[on_wave]["subsequent"]:
			_spawn_zert()
		else:
			for i in range(waves[on_wave]["zerts"]):
				#print("spawning in!!!!")
				var delay = waves[on_wave]["zert_delay"] * i
				_spawn_zert_async_internal_func_dont_use(delay)
	
	pass

func _spawn_enemt():
	#print_debug("SPAWNed enemt")
	
	var radius = zone.get_child(0).shape.radius
	
	var angle = randf() * TAU
	var r = sqrt(randf()) * radius
	
	var local_pos = Vector3(r * cos(angle), 0, r * sin(angle))
	var world_pos = zone.global_transform.origin + local_pos
	world_pos.y = 1.0
	
	var enemt = preload("res://entities/enemt/enemt.tscn").instantiate()
	enemt.name = "Enemt" + str(randi())
	enemt.global_transform.origin = world_pos
	enemt.rng_shard_drops = false
	
	Globals.root_node_3d.add_child(enemt)

func _spawn_enemt_async_internal_func_dont_use(delay: float):
	await get_tree().create_timer(delay).timeout
	_spawn_enemt()

func _spawn_zert():
	var randomIsland = randi_range(0, 3)
	
	# keep retrying until an island is not populated
	if island_populated[randomIsland]:
		await get_tree().create_timer(0.1).timeout
		_spawn_zert()
		return
	
	_spawn_zert_at_island(randomIsland + 1)

func _spawn_zert_async_internal_func_dont_use(delay: float):
	await get_tree().create_timer(delay).timeout
	_spawn_zert()

func _spawn_zert_at_island(island: int):
	var zert = preload("res://entities/zert/zert.tscn").instantiate()
	zert.name = "Zert" + str(randi())
	zert.drops_shards = false
	zert.line_path_length = 0.5
	zert.instant_despawn = true
	zert.vision_cone = 45
	zert.vision_range = 15.0
	
	match island:
		1:
			island_1.global_position.y = 0.0
			zert.global_transform.origin = island_1_spawnpoint.global_position
			zert.line_path_angle = 90
			zert.array_death_log = 1
			island_populated[0] = true
			
			island_1.visible = true
		2:
			island_2.global_position.y = 0.0
			zert.global_transform.origin = island_2_spawnpoint.global_position
			zert.line_path_angle = 0
			zert.array_death_log = 2
			island_populated[1] = true
			
			island_2.visible = true
		3:
			island_3.global_position.y = 0.0
			zert.global_transform.origin = island_3_spawnpoint.global_position
			zert.line_path_angle = 270
			zert.array_death_log = 3
			island_populated[2] = true
			
			island_3.visible = true
		4:
			island_4.global_position.y = 0.0
			zert.global_transform.origin = island_4_spawnpoint.global_position
			zert.line_path_angle = 180
			zert.array_death_log = 4
			island_populated[3] = true
			
			island_4.visible = true
	
	Globals.root_node_3d.add_child(zert)


# ty https://forum.godotengine.org/t/formatting-a-timer/6482/2
func _format_time(time: float) -> String: 
	var minutes = time / 60
	var seconds = fmod(time, 60)
	var milliseconds = fmod(time, 1) * 100
	return "%01d:%02d.%02d" % [minutes, seconds, milliseconds]
