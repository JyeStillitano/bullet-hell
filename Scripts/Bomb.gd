extends Projectile
class_name Bomb

func _ready() -> void:
	super._ready()
	
	# Start "Fire" animation.
	$Sprite.play("Fire")
	
func _on_body_entered(body: Node) -> void:
	super._on_body_entered(body)
	
	# Start "Collide" animation.
	$Sprite.play("Collide")
	
func _on_death_timer_timeout() -> void:
	queue_free()
