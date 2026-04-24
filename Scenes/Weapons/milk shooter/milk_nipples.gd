extends BaseWeapon

var fire_timer: float = 0.0
@export var base_damage: float = 1.0

func _physics_process(delta: float) -> void:
	
	look_at(get_global_mouse_position())

func shoot(aim_direction: Vector2) -> void:
	var final_damage = base_damage
	if owner and "base_damage_mult" in owner:
		final_damage = base_damage * owner.base_damage_mult
		
	if not can_shoot or projectile_scene == null: 
		return
		
	can_shoot = false
	

	var drop = projectile_scene.instantiate()
	drop.damage = final_damage
	drop.global_position = %ShootingPoint.global_position
	drop.global_rotation = %ShootingPoint.global_rotation
	get_tree().current_scene.add_child(drop)
	
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
