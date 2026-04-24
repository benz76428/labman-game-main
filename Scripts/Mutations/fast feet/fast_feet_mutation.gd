extends Mutation
class_name FastFeetMutation

@export var speed_increase: float = 50.0


func apply_mutation(player: Node2D):
	# Assuming your player script has a 'speed' or 'SPEED' variable
	if "base_speed" in player:
		player.base_speed += speed_increase
	elif "BASE_SPEED" in player:
		player.base_SPEED += speed_increase
		
	print("Player speed increased by ", speed_increase)
