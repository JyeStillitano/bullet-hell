extends Camera2D
class_name Camera

enum CameraState {
	Normal,
	ZoomIn,
	ZoomOut,
	Shake
}

var camera_state: CameraState = CameraState.Normal

@export var decay: float = 0.8
@export var max_offset: Vector2 = Vector2(10, 8)
var camera_offset: Vector2 = Vector2(100, 80)
@export var max_roll: float = 1.0
#@onready var target

var zoom_target: Node2D
@export var zoom_level: float = 2.0
@export var zoom_decay: float = 10

var strength: float = 1.0
var current_strength: float = 0.0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _process(delta):
	
	if zoom.x > 1: 
		zoom.x = max(zoom.x - (zoom_decay * delta), 1)
		zoom.y = max(zoom.y - (zoom_decay * delta), 1)
	
	if current_strength:
		current_strength = max(current_strength - decay * delta, 0)
		shake()
	pass

func add_shake(amount: float) -> void:
	current_strength = min(current_strength + amount, 1.0)

func shake() -> void:
	var amount = pow(current_strength, strength)
	rotation = max_roll * amount * rng.randf_range(-1, 1)
	offset.x = (max_offset.x * amount * rng.randf_range(-1, 1)) + camera_offset.x
	offset.y = (max_offset.y * amount * rng.randf_range(-1, 1)) + camera_offset.y
	pass
