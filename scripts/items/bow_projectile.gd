extends RayCast3D


@export var vector_rotation = ""
@export var speed := 5.0

@onready var timer: Timer = $Timer2

#var lerp := 0
var elapsed_time := 0.0

var collided: bool = false

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
		
		if get_collider().name.contains("Zert") or get_collider().name.contains("Enemt"):
			print("hit enemy")
			var entity = get_collider()
			
			entity.health -= Globals.item_info_dict[Globals.equipment[Globals.slot_active - 1]]["damage"]
			entity.attack_event = self.rotation.y + PI
			timer.start()

func cleanup() -> void:
	queue_free()
