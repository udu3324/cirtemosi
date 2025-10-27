extends RayCast3D

# ty bramwell!! https://www.youtube.com/watch?v=vGpFwaLUG4U

# it took so long to debug why animations were affecting all instances...
# https://stackoverflow.com/a/77131615/16216937

@export var vector_rotation = ""
@export var speed := 5.0

@onready var mesh: SphereMesh = $MeshInstance3D.mesh
@onready var material: StandardMaterial3D = mesh.material

@onready var timer: Timer = $Timer2
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

#var lerp := 0
var elapsed_time := 0.0

var collided: bool = false

var max_size: float = 0.6

func _ready():
	#print("spawned one in", elapsed_time)
	max_size = randf_range(0.4, 1.0)

func _process(delta: float):
	
	if !collided:
		return
	
	if timer.is_stopped():
		timer.start()
	
	#print("name is", name, mesh, material)
	
	elapsed_time += delta
	
	material.emission_energy_multiplier = remap(elapsed_time, 0, 0.3, 0.5, 1.5)
	
	mesh.radius = clamp(remap(elapsed_time, 0, 0.1, 0.2, max_size / 2), 0.2, max_size / 2)
	mesh.height = clamp(remap(elapsed_time, 0, 0.1, 0.4, max_size), 0.4, max_size)

func _physics_process(delta: float) -> void:
	
	position += global_basis * Vector3.FORWARD * speed * delta
	target_position = Vector3.FORWARD * speed * delta
	force_raycast_update()
	#var collider = get_collider()
	if is_colliding():
		collided = true
		global_position = get_collision_point()
		set_physics_process(false)
		
		#print("collided with", get_collider().name)
		
		if get_collider().name.contains("Player"):
			var force_push = Vector3(-cos(vector_rotation), 0, sin(vector_rotation)).normalized()
			#DebugDraw3D.draw_sphere(force_push, 0.5, Color.AQUA)
			Globals.player_pushback_event = force_push * randi_range(2, 5)
			Globals.player_physics_reset_event = true
			
			Globals.health -= 1 if Globals.easy_mode else 3
			Globals.player_vignette_event = true

func cleanup() -> void:
	queue_free()
