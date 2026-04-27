extends Resource
class_name Mutation

@export var mutation_name: String
@export var mutation_description: String

# The exact name of the stat in the dictionary to upgrade (e.g., "speed_multiplier")
@export var target_stat: String 

@export var max_level: int = 5
@export var base_value: float = 0.05    
@export var upgrade_value: float = 0.025 

var current_level: int = 0 

func apply_mutation(player: Node2D):
	if current_level >= max_level:
		print(mutation_name, " is already at max level!")
		return 
		
	# Decide how much to add based on the level
	var amount_to_add = base_value if current_level == 0 else upgrade_value
	
	# Pass the stat name and the amount to the player's new dictionary function
	if player.has_method("modify_stat"):
		player.modify_stat(target_stat, amount_to_add)
		
	current_level += 1
