extends BaseWeapon

var fire_timer: float = 0.0
@export var base_damage: float = 1.0

func _physics_process(delta: float) -> void:
	# Always point at the mouse
	look_at(get_global_mouse_position())
	
	# Count down the cooldown
	if fire_timer > 0:
		fire_timer -= delta
		
func shoot(aim_dir: Vector2) -> void:
	# ONLY shoot if the cooldown timer is at or below zero
	var final_damage = base_damage
	if owner and "damage_multiplier" in owner:
		final_damage = base_damage * owner.base_damage_mult
	
	if fire_timer <= 0:
		const BULLET = preload("res://Scenes/Weapons/pistol/bullet.tscn")
		var new_bullet = BULLET.instantiate()
		new_bullet.damage = final_damage
		new_bullet.global_position = %ShootingPoint.global_position 
		new_bullet.global_rotation = %ShootingPoint.global_rotation 
		
		# Add to the main scene tree
		get_tree().current_scene.add_child(new_bullet)

		fire_timer = fire_rate
