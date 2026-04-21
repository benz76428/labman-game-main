extends Area2D

const SPEED = 400.0
const MAX_RANGE = 1000.0
var travelled_distance = 0.0
var damage = 1 

func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	
	travelled_distance += SPEED * delta
	if travelled_distance > MAX_RANGE:
		queue_free()



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free() # Destroy projectile after hitting player
