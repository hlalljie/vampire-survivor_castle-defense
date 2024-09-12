extends Area2D

@export_enum("Cooldown", "HitOnce", "DisableHitBox") var HurtBoxType: int = 0

@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableTimer

## Sends damage when hurt
signal hurt(damage: int, angle: Vector2, knockback: int)

var hit_once_list: Array = []

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
					# add to the already hit once list if not in it
					if not hit_once_list.has(area):
						hit_once_list.append(area)
						# if the item can be destroyed, attach the remove signal to erase it when destroyed
						if area.has_signal("remove_from_list"):
							if not area.is_connected("remove_from_list", Callable(self, "remove_object_from_list")):
								area.connect("remove_from_list", Callable(self, "remove_object_from_list"))
					# otherwise ignore damage
					else:
						return
				2: # DisableHitBox
					if area.has_method("temp_disable"):
						# temporarily disables the hitbox of the attacker
						area.temp_disable()
			
			# collect hurt infomormation from damaging party
			var damage = area.damage
			var angle: Vector2 = Vector2(0.0, 0.0)
			var knockback: int = 1
			# get ventor of knockback
			if not area.get("angle") == null:
				angle = area.angle
			if not area.get("knockback_amount") == null:
				knockback = area.knockback_amount
			
			# send hurt signal
			hurt.emit(damage, angle, knockback)
			# respond to projectile with hp to register a hit
			if area.has_method("enemy_hit"):
				area.enemy_hit(1)

func remove_object_from_list(object: Object):
	if hit_once_list.has(object):
		hit_once_list.erase(object)
	

## Stop disabling hurtbox on timeout
func _on_disable_timer_timeout() -> void:
	collision.call_deferred("set", "disabled", false)
