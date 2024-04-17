extends Node2D

@export var player_scene: PackedScene
@export var enemy_scene: PackedScene
var player: Player
var enemy: Enemy

@export var game_over_delay = 3
var game_state: GameState
var score: int = 1

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var screen_size: Vector2

const start_text = "Survive \n\nPress \"Space\""
const win_text = "Victory!"
const lose_text = "Failure!"

enum GameState {
	Start,
	Play,
	Win,
	Lose,
	GameOver
}

func _ready():
	$GameOverTimer.wait_time = game_over_delay
	game_state = GameState.Start
	$UI/TextContainer/Text.text = start_text
	$UI/Score.text = str(score)
	
	screen_size = get_viewport_rect().size

func _process(delta: float):
	match game_state:
		GameState.Start: start(delta)
		GameState.Play: play(delta)
	pass

func _input(event: InputEvent):
	# Quit.
	if event.is_action_pressed("Quit"):
		get_tree().quit()

func start(_delta: float) -> void:	
	# If player presses "Space" start game, play state.
	if Input.is_action_just_pressed("Interact"): 
		game_state = GameState.Play
		$UI/TextContainer/Text.visible = false
		$SFX/Start.play()
		
		# Setup Player
		if !player: spawn_player()
		
		# Setup Enemies
		if get_tree().get_nodes_in_group("Enemies").size() < score: spawn_enemies()
	pass

func play(_delta: float) -> void:
	# If Player dies, lose state.
	if !player:
		game_state = GameState.GameOver
		$UI/TextContainer/Text.text = lose_text
		$UI/TextContainer/Text.visible = true
		score = max(score - 1, 1)
		$UI/Score.text = str(score)
		$GameOverTimer.start()
		return
	
	# If all enemies dead, win state.		
	if get_tree().get_nodes_in_group("Enemies").size() == 0:
		$Camera.add_shake(0.50)
		game_state = GameState.GameOver
		$UI/TextContainer/Text.text = win_text
		$UI/TextContainer/Text.visible = true
		score += 1
		$UI/Score.text = str(score)
		$GameOverTimer.start()
		return
		
	pass

func spawn_player() -> void:
	
	player =  player_scene.instantiate()
	add_child(player)
	player.global_position = get_random_spawn()
	player.died.connect(_on_entity_died)
	pass

func spawn_enemies() -> void:
	
	#region Unused "check random spawn" code.
	#var spawn_found: bool = false
	#while(!spawn_found):
	#	spawn_found = true
	#	spawn_point = Vector2(rng.randi_range(0, screen_size.x), rng.randi_range(0, screen_size.y))
	#	$SpawnRayCast.position = spawn_point
	#	for i in range(4):
	#		if $SpawnRayCast.is_colliding(): spawn_found = false
	#		$SpawnRayCast.rotate(90.0)
	#endregion
	
	for i in max(score - get_tree().get_nodes_in_group("Enemies").size(), 1):
		enemy = enemy_scene.instantiate()
		add_child(enemy)
		enemy.global_position = get_random_spawn()
		enemy.died.connect(_on_entity_died)
	pass

func get_random_spawn() -> Vector2: return Vector2(rng.randf_range(5, screen_size.x - 5), rng.randf_range(5, screen_size.y - 5))

func _on_entity_died(): $Camera.add_shake(0.25)
func _on_game_over_timer_timeout():
	$UI/TextContainer/Text.text = start_text
	game_state = GameState.Start
	pass # Replace with function body.
