extends Enemy

func _on_hurt_box_hurt(damage: int, angle: Vector2, knockback_amount: int) -> void:
	# lowers hp based on damage recieved
	hp -= damage
	print("Boss Hp:", hp)
	#print("Enemy hit %d for damage. Enemy HP now: %d" %[damage, hp])
	# calculate the knockback vector based on angle and amount
	knockback = angle * knockback_amount
	# hit that kills
	if hp <= 0:
		death()
	# hit that doesn't kill
	else:
		sound_hit.play()

func death():
	#print("Enemy killed")
	remove_from_list.emit(self)
	# trigger death explosion
	var enemy_death: Sprite2D = death_anim.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	
	# Drop experience
	var new_gem: Area2D = exp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child", new_gem)

	print("You really win!")
	# deletes the enemy from the scene
	queue_free()
