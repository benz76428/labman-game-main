extends NodeState

@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D

func _on_physics_process(_delta: float) -> void:
	# Get the input direction
	var direction: Vector2 = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	
	if player:
		if direction != Vector2.ZERO:
			player.player_direction = direction
			
		var current_speed = player.get_stat("speed")
		var current_mult = player.get_stat("speed_multiplier")
		
		# Apply the math
		player.velocity = direction * (current_speed * current_mult)
		player.move_and_slide()
	
	# Animation Logic
	var anim_name = "walk_front"
	if direction != Vector2.ZERO:
		# Use absolute values to determine the 'Dominant Axis'
		# This checks if you are moving more vertically or horizontally
		if abs(direction.y) > abs(direction.x):
			# More vertical movement
			if direction.y < 0:
				anim_name = "walk_back"
			else:
				anim_name = "walk_front"
		else:
			# More horizontal movement
			if direction.x < 0:
				anim_name = "walk_left"
			else:
				anim_name = "walk_right"
	
	animated_sprite_2d.play(anim_name)

func _on_next_transitions() -> void:
	# If we stop moving, go back to Idle
	if Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down") == Vector2.ZERO:
		transition.emit("Idle")
