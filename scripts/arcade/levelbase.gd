extends Node3D

@onready var leaderboard_label: Label = $SubViewport/CenterContainer/VBoxContainer/Label

@onready var zone = $IslandFight/Area3DSpawn
@onready var bridge = $Bridge

@onready var arcade = preload("res://assets/audio/soundtrack/cirtemosi-arcade.ogg")

@onready var waves = {
	1: { # spawn 4 enemts all spaced out
		"subsequent": true,
		"enemts": 3,
		"enemt_delay": 1.5,
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
		"enemt_delay": 7.0,
		"zerts": 0,
		"zert_delay": 0,
		"weapon_damage": 25
	},
	4: { # spawn 4 enemts all at once with a delay
		"subsequent": false,
		"enemts": 4,
		"enemt_delay": 0.0,
		"zerts": 0,
		"zert_delay": 0,
		"weapon_damage": 30
	},
}

var leaderboard_data
var save_a_new_data: bool = false

var on_wave: int = 0
var time_elapsed: float = 0.0
var started: bool = false
var stop_timer: bool = false

var wave_enemt_deaths: int = 0
var wave_zert_deaths: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# load the leaderboard
	DB.leaderboard_request_completed.connect(_on_leaderboard_loaded)
	DB.fetch_top(16)
	

func _on_leaderboard_loaded(data) -> void:
	
	# handle strange data in case? idk lol
	if typeof(data) == TYPE_DICTIONARY and data.has("leaderboard"):
		leaderboard_data = data["leaderboard"]
	elif typeof(data) == TYPE_ARRAY:
		leaderboard_data = data
	else:
		leaderboard_data = []
	
	leaderboard_label.text = "wave | time | player | shards \n"
	
	for score in data:
		var player_name = score.player_name
		var wave = score.wave
		var time = _format_time(score.time)
		var shards = score.shards
		var easy_mode = score.easy_mode
		
		#leaderboard_label.text += str(count) + " - " + player_name + " | wave " + str(wave) + " | " + time + " | " + str(shards) +  " shards"
		leaderboard_label.text += String.num_int64(wave) + " - " + time + " - " + player_name + " - " + String.num_int64(shards) + " shards"
		
		if easy_mode:
			leaderboard_label.text += " (easymode)"
		
		leaderboard_label.text += "\n"
	
	# move somewhere else todo
	if save_a_new_data:
		save_a_new_data = false
		print("triggered save new leaderboard pos ", on_wave, time_elapsed, Globals.shards, Globals.easy_mode)
		
		var new_entry = {
			"player_name": str(randi()),
			"wave": on_wave,
			"time": time_elapsed,
			"shards": Globals.shards,
			"easy_mode": Globals.easy_mode
		}
		
		leaderboard_data.append(new_entry)
		
		#Shibadb.save_progress({ "leaderboard": leaderboard_data })

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# handle count up time
	if started and !stop_timer:
		time_elapsed += delta
		Globals.arcade_time.text = _format_time(time_elapsed)
	
	if on_wave == 0:
		return
	
	# handle goals
	if waves[on_wave]["enemts"] == wave_enemt_deaths and waves[on_wave]["zerts"] == wave_zert_deaths:
		
		# i hate my life as well as asynchronous code
		wave_enemt_deaths = 0
		wave_zert_deaths = 0
	
		Globals.arcade_title.text = "cleared!"
		
		await get_tree().create_timer(2).timeout
		Globals.arcade_title.text = ""
		await get_tree().create_timer(0.4).timeout
		Globals.health = Globals.health_max
		await get_tree().create_timer(0.8).timeout
		
		if on_wave == 1:
			_start_wave(2)
		elif on_wave == 2:
			_start_wave(3)
		elif on_wave == 3:
			_start_wave(4)
		else:
			stop_timer = true
			Globals.arcade_title.text = "finished!"
			Globals.arcade_description.text = "\n\n\nplease walk off the\nisland for now to\ngo back to the main\nmenu."
			
			#save_a_new_data = true
			#Shibadb.load_progress()
	
	
	if Globals.enemt_deaths[0] >= 1: # handle a enemt death
		var difference = Globals.enemt_deaths[0]
		Globals.enemt_deaths[0] = 0
		
		wave_enemt_deaths += difference
		Globals.arcade_description.text = "enemt " + str(wave_enemt_deaths) + "/" + str(waves[on_wave]["enemts"])
		
		if waves[on_wave]["subsequent"] and wave_enemt_deaths != waves[on_wave]["enemts"]:
			await get_tree().create_timer(waves[on_wave]["enemt_delay"]).timeout
			#print("just one 4now")
			_spawn_enemt()

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
	
	Globals.arcade_title.text = "wave " + str(wave)
	Globals.arcade_description.text = ""
	
	Globals.item_info_dict[Globals.equipment[Globals.slot_active - 1]]["damage"] = waves[on_wave]["weapon_damage"]
	
	#print_debug("new wave spacer")
	if waves[on_wave]["enemts"] != 0:
		Globals.arcade_description.text += "enemt " + str(wave_enemt_deaths) + "/" + str(waves[on_wave]["enemts"]) + "\n"
		
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
		Globals.arcade_description.text += "zert " + str(wave_zert_deaths) + "/" + str(waves[on_wave]["zerts"]) + "\n"
	
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

# ty https://forum.godotengine.org/t/formatting-a-timer/6482/2
func _format_time(time: float) -> String: 
	var minutes = time / 60
	var seconds = fmod(time, 60)
	var milliseconds = fmod(time, 1) * 100
	return "%01d:%02d.%02d" % [minutes, seconds, milliseconds]
