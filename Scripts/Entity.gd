extends RigidBody2D
class_name Entity

# Position Properties
@export var start_position: Vector2

# Health Properties
@export var max_health: int = 1
var health: int = max_health
var alive: bool = true

# Speed Properties
@export var base_speed: float = 5.0
var speed: float = base_speed

# Boost Properties
@export var boost_force: float = 10000.0
@export var boost_force_cooldown: float = 2
@export var boost_speed: float = 3.0
@export var boost_speed_cooldown: float = 0.5
var boost_ready: bool = true

# Primary Projectile Properties
@export var primary_projectile: PackedScene
@export var primary_projectile_fire_rate: float = 0.3 # Fire every primary_fire_rate seconds.
var primary_fire_ready: bool = true

# Secondary Projectile Properties
@export var secondary_projectile : PackedScene
@export var secondary_projectile_fire_rate : float = 1.2 # Fire every secondary_fire_rate seconds.
var secondary_fire_ready: bool = true

# Signals
signal died

# Initialise Entity
func _ready():	
	position = start_position
	max_contacts_reported = health
	$Sprite.play("Fly")
	$BoostForceTimer.wait_time = boost_force_cooldown
	$BoostSpeedTimer.wait_time = boost_speed_cooldown
	$PrimaryProjectileTimer.wait_time = primary_projectile_fire_rate
	$SecondaryProjectileTimer.wait_time = secondary_projectile_fire_rate

# Physics movement in "direction".
func move(direction: Vector2, state: PhysicsDirectBodyState2D) -> void:	
	# Apply central force in direction.
	var force: Vector2 = direction.normalized() * speed * state.step * 10000
	state.apply_central_force(force)

# Impulse physics boost in "direction".
func boost(direction: Vector2, state: PhysicsDirectBodyState2D) -> void:
	# If no direction given, don't boost.
	if direction == Vector2.ZERO: return
	
	if !boost_ready: return
	boost_ready = false
	$Sprite.play("Boost")
	$BoostSound.play()
	$BoostForceTimer.start()
	
	# Apply impulse force in direction.
	var impulse: Vector2 = direction * boost_force * state.step
	state.apply_central_impulse(impulse)
	
	boost_movement_speed()

# Double speed.
func boost_movement_speed() -> void:
	$BoostSpeedTimer.start()
	speed = speed * 2

# Set speed to base_speed.
func normalise_movement_speed() -> void:
	speed = base_speed

# Look at "target_position".
func look_at_position(target_position: Vector2) -> void:
	$Sprite.look_at(target_position)

# Fire "projectile" straight.
func shoot(projectile: PackedScene, friendly: bool) -> void:
	var instance: Projectile = projectile.instantiate()
	instance.position = $Sprite/FirePoint.global_position
	instance.rotation = $Sprite.rotation
	instance.set_friendly(friendly)
	get_parent().add_child(instance)
	$Sprite/FirePoint/Particles.restart()

# Take "amount" damage to health.
func damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		$Sprite.play("Die")
		die()

# Remove Entity
func die() -> void:
	$ExplosionSound.play()
	alive = false
	$QueueFreeTimer.start()
	died.emit()

# Timers
func on_boost_force_timer_timeout(): 
	boost_ready = true
	$RechargeSound.play()
func on_boost_speed_timer_timeout(): 
	normalise_movement_speed()
	$Sprite.play("Fly")
func on_primary_projectile_timer_timeout(): primary_fire_ready = true
func on_secondary_projectile_timer_timeout(): secondary_fire_ready = true
func _on_queue_free_timer_timeout(): queue_free()
