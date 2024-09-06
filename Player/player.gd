extends CharacterBody2D

# Global variables
var movement_speed: float = 60.0
var hp: int = 80

# imports from local nodes
@onready var sprite: Sprite2D = $Sprite2D
@onready var walkTimer: Timer = get_node("%WalkTimer") # use Access with Unique Name on node

# Attacks
var iceSpear: Resource = preload("res://Player/Attack/ice_spear.tscn")
var tornado: Resource = preload("res://Player/Attack/tornado.tscn")
var javelin: Resource = preload("res://Player/Attack/javelin.tscn")

# Attack Nodes
@onready var iceSpearTimer: Timer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer: Timer = get_node("%IceSpearAttackTimer")
@onready var tornadoTimer: Timer = get_node("%TornadoTimer")
@onready var tornadoAttackTimer: Timer = get_node("%TornadoAttackTimer")
@onready var javelinBase: Node2D = get_node("%JavelinBase")

# Ice Spear
var ice_spear_ammo: int = 0
var ice_spear_base_ammo: int = 3
var ice_spear_attack_speed: float = 1.5
var ice_spear_level: int = 1

# Tornado
var tornado_ammo: int = 0
var tornado_base_ammo: int = 3
var tornado_attack_speed: float = 3.0
var tornado_level: int = 1

# Javelin
var javelin_ammo: int = 3
var javelin_level: int = 1

var last_movement: Vector2 = Vector2.UP

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
		
		# update last movement, rounding brings diagonal unit vector to 1, 1 (instead of .7, .7)
		last_movement = move.round()
	
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
	if tornado_level > 0:
		# set up the timer with the wait time
		tornadoTimer.wait_time = tornado_attack_speed
		# start the timer
		if tornadoTimer.is_stopped():
			tornadoTimer.start()
	if javelin_level > 0:
		spawn_javelin()

## Lowers hp based on damage recieved
func _on_hurt_box_hurt(damage: int, _angle, _knockback) -> void:
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
			
## Gain ammo every time the timer is up
func _on_tornado_timer_timeout() -> void:
	tornado_ammo += tornado_base_ammo
	tornadoAttackTimer.start()

## Fire a shot if there is ammo and if the timer is up
func _on_tornado_attack_timer_timeout() -> void:
	# check if there is ammo
	if tornado_ammo > 0:
		# create an ice spear
		var tornado_attack: Area2D = tornado.instantiate()
		# set it's position to the player's position
		tornado_attack.position = position
		# finds a random target direction
		tornado_attack.last_movement = last_movement
		# set the level to the current level
		tornado_attack.level = tornado_level
		# add ice spear to the scene
		add_child(tornado_attack)
		# use the ammo
		tornado_ammo -= 1
		# fire off more ice spears if ammo exists
		if tornado_ammo > 0:
			tornadoAttackTimer.start()
		else: 
			tornadoAttackTimer.stop()
## Spawns as many javelins as there is ammo
func spawn_javelin():
	# create as many javelins as are needed (how much javelin ammo)
	var current_javelin_total: int = javelinBase.get_child_count()
	var calc_spawns: int = javelin_ammo - current_javelin_total
	# continue to spawn javelins as needed
	while calc_spawns > 0:
		var javelin_spawn: Area2D = javelin.instantiate()
		javelin_spawn.global_position = global_position
		javelinBase.add_child(javelin_spawn)
		calc_spawns -= 1
	
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
