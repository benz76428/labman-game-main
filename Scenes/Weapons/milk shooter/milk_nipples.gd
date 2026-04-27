extends BaseWeapon # <-- Now it inherits all the auto-targeting logic!

# Make sure this matches your marker node name (e.g., $Muzzle, $Marker2D, etc.)
# If you have two muzzles (since it's plural!), let me know and we can make it shoot from both!
@onready var muzzle = $Muzzle 

# This overrides the blank function in the base class!
func shoot(target: Node2D):
	if not projectile_scene: 
		print("ERROR: No milk projectile scene attached!")
		return
		
	var new_milk = projectile_scene.instantiate()
	
	# Point the weapon exactly at the closest enemy!
	look_at(target.global_position)
	
	# Calculate damage using the player's dictionary
	var final_damage = base_damage
	if player and player.has_method("get_stat"):
		final_damage = base_damage * player.get_stat("damage_multiplier")
	
	# Set up the projectile
	new_milk.damage = final_damage
	
	# If you don't have a Muzzle node, you can just use `global_position` instead
	if muzzle:
		new_milk.global_position = muzzle.global_position
	else:
		new_milk.global_position = global_position
		
	new_milk.rotation = global_rotation
	
	# Add the projectile to the world
	get_tree().current_scene.add_child(new_milk)
