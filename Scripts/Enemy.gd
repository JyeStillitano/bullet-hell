extends Entity
class_name Enemy

@export var player_target: Entity

@export var change_direction_cooldown: float = 1
var change_direction_ready: bool = false

@export var charge_cooldown: float = 5
var charge_ready: bool = false

var move_direction: Vector2

var fire_ready: bool = false
var fire_rate: float = 2.0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	super._ready()
	move_direction = (get_viewport_rect().size / 2) - position

	$ChangeDirectionTimer.wait_time = change_direction_cooldown
	$ChangeDirectionTimer.start()
	$ChargeTimer.wait_time = charge_cooldown
	$ChargeTimer.start()

	$ShootTimer.wait_time = fire_rate
	$ShootTimer.start()

	if get_parent().has_node("Player"):
		player_target = get_parent().get_node("Player")

# Process Actions
func _process(_delta):
	if(!alive): return
	
	# If player_target killed, update target.
	if !is_instance_valid(player_target):
		if get_parent().has_node("Player"):
			player_target = get_parent().get_node("Player")
	
	# Random directions.
	if change_direction_ready: change_direction()
	
	# Attacks
	if fire_ready:
		fire_ready = false
		$ShootTimer.start()
		shoot(primary_projectile, false)
	
	change_rotation()

# Physics Actions
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if(!alive): return
	move(move_direction, state)
	#move(Vector2.from_angle(rotation_degrees), state)

# Update Direction
func change_direction() -> void:
	# Reset timer.
	$ChangeDirectionTimer.start()
	change_direction_ready = false
	
	var new_direction: Vector2
	
	# If "charge_ready", target player.
	if charge_ready && is_instance_valid(player_target):
		$ChargeTimer.start()
		charge_ready = false
		new_direction = player_target.position - position
	else:
		# Find centre of screen.
		var screen_centre: Vector2 = get_viewport_rect().size / 2
		# Add randomness
		var randomness: Vector2 = Vector2(rng.randf_range(-50, 50), rng.randf_range(-50, 50))
		new_direction = screen_centre - position + randomness
	
	move_direction = new_direction

# Update Rotation
func change_rotation() -> void:
	if is_instance_valid(player_target): 
		look_at_position(player_target.position)
	else:
		$Sprite.look_at(position + move_direction)

# Collision
func _on_body_entered(body: Node) -> void:
	if(!alive): return
	
	# Check what hit
	if body is Projectile: damage(1)
	if body is Bomb: damage(3)

# Timers
func on_change_direction_timer_timeout(): change_direction_ready = true
func on_charge_timer_timeout(): charge_ready = true


func on_shoot_timer_timeout(): fire_ready = true
