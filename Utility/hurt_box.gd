extends Area2D

@export_enum("Cooldown", "HitOnce", "DisableHitBox") var HurtBoxType: int = 0

@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableTimer

## Sends damage when hurt
signal hurt(damage: int)


func _on_area_entered(area: Area2D) -> void:
	# checks attacks
	if area.is_in_group("attack"):
		# if the attack does damage
		if not area.get("damage") == null:
			# does effects based on what type of damage
			match HurtBoxType:
				0: #Cooldown
					# disables the hurtbox of the victim
					collision.call_deferred("set", "disabled", true)
					# activates the cooldown timer, 
					# which will reactive the hurtbox once done
					disableTimer.start()
				1: # HitOnce
					pass
				2: # DisableHitBox
					if area.has_method("temp_disable"):
						# temporarily disables the hitbox of the attacker
						area.temp_disable()
			var damage = area.damage
			emit_signal("hurt", damage)
			# respond to projectile with hp to register a hit
			if area.has_method("enemy_hit"):
				area.enemy_hit(1)

## Stop disabling hurtbox on timeout
func _on_disable_timer_timeout() -> void:
	collision.call_deferred("set", "disabled", false)
