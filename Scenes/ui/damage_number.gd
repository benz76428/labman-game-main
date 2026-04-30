extends Marker2D

func popup(damage_amount: int, start_position: Vector2):
	# Set the text to the damage amount
	$Label.text = str(damage_amount)
	
	# Move the number to where the enemy got hit
	global_position = start_position
	
	# Create an animation (Tween)
	var tween = get_tree().create_tween()
	tween.set_parallel(true) # Run animations at the same time
	
	# Move it up 50 pixels over 0.5 seconds
	tween.tween_property(self, "global_position:y", global_position.y - 50, 0.5)
	
	# Fade out the opacity (modulate:a) over 0.5 seconds
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	
	# When the animation finishes, delete this node
	tween.chain().tween_callback(queue_free)
