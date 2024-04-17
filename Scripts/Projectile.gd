extends RigidBody2D
class_name Projectile

@export var impulse_speed: float = 50
@export var constant_speed: float = 50

#@export var dampening: float = 10
var fired: bool = false

func _ready():
	# Set queue free timer to match collision sound length.
	$QueueFreeTimer.wait_time = $SFX/Collide.stream.get_length() / 2

func _integrate_forces(state: PhysicsDirectBodyState2D):
	# Get direction from current rotation.
	var direction: Vector2 = Vector2.from_angle(rotation)
	
	# Apply impulse force and "Fire" sound.
	if (!fired):
		fired = true
		apply_central_impulse(direction * impulse_speed * state.step)
		$SFX/Fire.play()
	
	# Apply constant force.
	if (constant_speed): apply_central_impulse(direction * constant_speed * state.step)

func _on_body_entered(_body):
	# Freeze movement.
	sleeping = true
	
	# Play "Collide" sound.
	$SFX/Collide.play()
	
	# Set queue free timer.
	$QueueFreeTimer.start()

func set_friendly(friendly: bool) -> void: 
	if friendly: 
		# Layer
		set_collision_layer(2)
		# Mask
		set_collision_mask(28)
	else: 
		# Layer
		set_collision_layer(8)
		# Mask
		set_collision_mask(19)

func _on_queue_free_timer_timeout():
	queue_free()
