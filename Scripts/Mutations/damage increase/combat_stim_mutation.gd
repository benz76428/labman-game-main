extends Mutation
class_name CombatStimMutation

func apply_mutation(player: Node2D):
	if current_level >= max_level:
		return 
		
	var amount_to_add = base_value if current_level == 0 else upgrade_value
	
	if "damage_multiplier" in player:
		player.damage_multiplier += amount_to_add
		
	current_level += 1
