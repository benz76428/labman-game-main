extends Mutation
class_name CombatStimMutation

# 0.15 equals a 15% overall damage boost
@export var damage_boost_percentage: float = 10000

func apply_mutation(player: Node2D):
	if "base_damage_mult" in player:
		player.base_damage_mult += damage_boost_percentage
		print("Combat Stim Applied! New multiplier: ", player.base_damage_mult)
