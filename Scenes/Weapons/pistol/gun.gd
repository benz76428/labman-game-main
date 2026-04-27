extends BaseWeapon # <-- Notice it extends our new class!

@onready var muzzle = $%ShootingPoint # Assuming you have a Marker2D node called Muzzle

# This overrides the blank function in the base class!
func shoot(target: Node2D):
	if not projectile_scene: 
		print("ERROR: No bullet scene attached to gun!")
		return
		
	var new_bullet = projectile_scene.instantiate()
	
	# Point the gun exactly at the closest enemy!
	look_at(target.global_position)
	
	# Calculate damage using the player's dictionary
	var final_damage = base_damage
	if player and player.has_method("get_stat"):
		final_damage = base_damage * player.get_stat("damage_multiplier")
	
	# Set up the bullet
	new_bullet.damage = final_damage
	new_bullet.global_position = muzzle.global_position
	new_bullet.rotation = global_rotation
	
	# Add the bullet to the world
	get_tree().current_scene.add_child(new_bullet)
