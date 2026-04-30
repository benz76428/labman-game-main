extends BaseWeapon 

@onready var muzzle = $%ShootingPoint 


func _on_fire_timer_timeout():
	if not projectile_scene: 
		print("ERROR: No milk projectile scene attached!")
		return
		
	var new_milk = projectile_scene.instantiate()
	
	if player and "player_direction" in player:
		rotation = player.player_direction.angle()
	# 1. Calculate damage using the player's dictionary
	var final_damage = base_damage
	if player and player.has_method("get_stat"):
		final_damage = base_damage * player.get_stat("damage_multiplier")
	
	new_milk.damage = final_damage
	
	# 2. Spawn it at the muzzle
	if muzzle:
		new_milk.global_position = muzzle.global_position
	else:
		new_milk.global_position = global_position
		
	# 3. Ask the player which way they are facing!
	if player and "player_direction" in player:
		# Convert their Vector2 direction (like [1, 0] for Right) into an angle
		new_milk.rotation = player.player_direction.angle()
	else:
		new_milk.rotation = 0 # Default to pointing right just in case
		
	# 4. Add the projectile to the world
	get_tree().current_scene.add_child(new_milk)
