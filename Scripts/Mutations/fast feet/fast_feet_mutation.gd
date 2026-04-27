extends Mutation
class_name FastFeetMutation

func apply_mutation(player: Node2D):
	if current_level >= max_level:
		return # Stop if it's already maxed out
		
	# 1. Simply decide which value to use in one line of code
	var amount_to_add = base_value if current_level == 0 else upgrade_value
	
	# 2. Apply it to the player
	if "speed_multiplier" in player:
		player.speed_multiplier += amount_to_add
		
	# 3. Increase the level
	current_level += 1
