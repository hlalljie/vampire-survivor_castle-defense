extends CharacterBody2D

# Global variables
var movement_speed: float = 60.0
var hp: int = 80

# imports from local nodes
@onready var sprite: Sprite2D = $Sprite2D
@onready var walkTimer: Timer = get_node("%WalkTimer") # use Access with Unique Name on node

# Attacks
var iceSpear: Resource = preload("res://Player/Attack/ice_spear.tscn")

# Attack Nodes
@onready var iceSpearTimer: Timer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer: Timer = get_node("%IceSpearAttackTimer")

# Ice Spear
var ice_spear_ammo: int = 0
var ice_spear_base_ammo: int = 1
var ice_spear_attack_speed: float = 1.5
var ice_spear_level: int = 1

var close_enemies: Array = []

func _ready() -> void:
	attack()

func _physics_process(delta: float) -> void:
	movement()
	
func movement() -> void:
	# Collect movement vector from input (either 0 or 1 for every direction)
	var move: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	# Face player sprite in correct direction
	if move.x > 0:
		sprite.flip_h = true
	elif move.x < 0:
		sprite.flip_h = false
		
	# Walk animation
	# only animate when moving
	if move != Vector2.ZERO:
		# if walk animation timer is done, go to next animation
		if walkTimer.is_stopped():
			# go to next animation (looping)
			sprite.frame = (sprite.frame + 1) % (sprite.hframes)
			# restart walk timer
			walkTimer.start()
	
	# set velocity as the unit vector of move multiplied by the movement speed
	velocity = move.normalized() * movement_speed
	# move and set to slide on collision
	move_and_slide()

## Starts all attacks
func attack() -> void:
	# if there is an ice spear activate
	if ice_spear_level > 0:
		# set up the timer with the wait time
		iceSpearTimer.wait_time = ice_spear_attack_speed
		# start the timer
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()

## Lowers hp based on damage recieved
func _on_hurt_box_hurt(damage: int) -> void:
	# lowers hp based on damage recieved
	hp -= damage
	print("Player hit %d for damage. Player HP now: %d" %[damage, hp])

## Gain ammo every time the timer is up
func _on_ice_spear_timer_timeout() -> void:
	ice_spear_ammo += ice_spear_base_ammo
	iceSpearAttackTimer.start()

## Fire a shot if there is ammo and if the timer is up
func _on_ice_spear_attack_timer_timeout() -> void:
	# check if there is ammo
	if ice_spear_ammo > 0:
		# create an ice spear
		var ice_spear_attack: Area2D = iceSpear.instantiate()
		# set it's position to the player's position
		ice_spear_attack.position = position
		# finds a random target direction
		ice_spear_attack.target = get_random_target()
		# set the level to the current level
		ice_spear_attack.level = ice_spear_level
		# add ice spear to the scene
		add_child(ice_spear_attack)
		# use the ammo
		ice_spear_ammo -= 1
		# fire off more ice spears if ammo exists
		if ice_spear_ammo > 0:
			iceSpearAttackTimer.start()
		else: 
			iceSpearAttackTimer.stop()

# Finds a random target direction from the list of close enemies
func get_random_target() -> Vector2:
	# check if there are any close enemies
	if close_enemies.size() > 0:
		return close_enemies.pick_random().global_position
	# default to up (for now)
	else:
		return Vector2.UP

## Add enemies to close enemies list when they get close
func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	# if not already in the detection area, add it to close enemies
	if not close_enemies.has(body):
		close_enemies.append(body)

## Remove enemies from close enemies list when they leave the area
func _on_enemy_detection_area_body_exited(body: Node2D) -> void:
	# if the enemy is still in close enemies, delete it
	if close_enemies.has(body):
		close_enemies.erase(body)
