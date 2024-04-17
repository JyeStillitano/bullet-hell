extends Entity
class_name Player

# Process Actions
func _process(_delta: float) -> void:
	if(!alive): return
	
	# Look at mouse.
	look_at_position(get_viewport().get_mouse_position())

# Physics Actions
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if(!alive): return
	
	# Move
	var direction: Vector2 = Input.get_vector("Left", "Right", "Up", "Down")
	move(direction, state)
	
	# Boost.
	if Input.is_action_pressed("Boost"): 
		boost(direction, state)

# Input
func _input(event: InputEvent) -> void:
	if(!alive): return
	
	# Primary Fire.
	if event.is_action_pressed("PrimaryFire") && primary_fire_ready:
		primary_fire_ready = false
		$PrimaryProjectileTimer.start()
		shoot(primary_projectile, true)
	
	# Secondary Fire.
	if event.is_action_pressed("SecondaryFire") && secondary_fire_ready:
		secondary_fire_ready = false
		$SecondaryProjectileTimer.start()
		shoot(secondary_projectile, true)

# Collision
func _on_body_entered(body: Node):
	if(!alive): return
	if body is Enemy and body.alive: damage(1)
	if body is Projectile: damage(1)
