extends CharacterBody2D

# enemy stats
@export var movement_speed: float = 20
@export var hp: int = 10
@export var knockback_recovery: float = 3.5
@export var exp = 1

# current knockback
var knockback: Vector2 = Vector2(0.0, 0.0)

# imported local variables (from node)
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sound_hit: AudioStreamPlayer2D = $sound_hit

# imported external variables (from other nodes)
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var loot_base: Node2D = get_tree().get_first_node_in_group("loot")

# Preloaded resources
var death_anim: Resource = preload("res://Enemy/explosion.tscn")
var exp_gem: Resource = preload("res://Objects/experience_gem.tscn")


signal remove_from_list(object: Object)

# runs once at the beginning
func _ready() -> void:
	# start animation
	anim.play("walk")


func _physics_process(delta: float) -> void:
	# apply knockback recovery to knockback
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	# Get the direction(unit vector) of the the enemy position towards the player position
	var direction: Vector2 = global_position.direction_to(player.global_position)
	# face enemy sprite in correct direction
	if direction.x > 0:
		sprite.flip_h = true
	elif direction.x < 0:
		sprite.flip_h = false

	# set velocity
	velocity = direction * movement_speed
	# apply knockback
	velocity += knockback
	# move and set to slide on collision
	move_and_slide()
	
func death():
	#print("Enemy killed")
	emit_signal("remove_from_list", self)
	# trigger death explosion
	var enemy_death: Sprite2D = death_anim.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	
	# Drop experience
	var new_gem: Area2D = exp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.exp = exp
	loot_base.call_deferred("add_child", new_gem)
	
	# deletes the enemy from the scene
	queue_free()


func _on_hurt_box_hurt(damage: int, angle: Vector2, knockback_amount: int) -> void:
	# lowers hp based on damage recieved
	hp -= damage
	#print("Enemy hit %d for damage. Enemy HP now: %d" %[damage, hp])
	# calculate the knockback vector based on angle and amount
	knockback = angle * knockback_amount
	# hit that kills
	if hp <= 0:
		death()
	# hit that doesn't kill
	else:
		sound_hit.play()
