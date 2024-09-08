extends Area2D

var level: int = 1
var hp: int = 9999
var speed: float = 200.0
var damage: int = 10
var knockback_amount: int = 100
var paths: int = 1
var attack_size: float = 1.0
var attack_speed: float = 4.0

var target: Vector2 = Vector2(0.0, 0.0)
var target_list: Array  = []

var angle: Vector2 = Vector2(0.0, 0.0)
var reset_pos: Vector2 = Vector2(0.0, 0.0)

var spr_jav_reg: Resource = preload("res://Textures/Items/Weapons/javelin_3_new.png")
var spr_jav_attack: Resource = preload("res://Textures/Items/Weapons/javelin_3_new_attack.png")

signal remove_from_list(object: Object)

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var attackTimer: Timer = get_node("%AttackTimer")
@onready var changeDirectionTimer: Timer = get_node("%ChangeDirection")
@onready var resetPosTimer: Timer = get_node("%ResetPosTimer")
@onready var  sound_attack: AudioStreamPlayer2D = $sound_attack

func _ready():
	# intially update the javelin stats to match level and start
	update_javelin()
	# let javelins move on start
	_on_reset_pos_timer_timeout()
	
func update_javelin():
	level = player.javelin_level
	match level:
		1:
			hp = 9999
			speed = 200.0
			damage = 10
			knockback_amount = 100
			paths = 1
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1 - player.spell_cooldown)
		# additional enemy per attack
		2:
			hp = 9999
			speed = 200.0
			damage = 10
			knockback_amount = 100
			paths = 2
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1 - player.spell_cooldown)
		# additional enemy per attack
		3:
			hp = 9999
			speed = 200.0
			damage = 10
			knockback_amount = 100
			paths = 3
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1 - player.spell_cooldown)
		# additional damage and knockback
		4:
			hp = 9999
			speed = 200.0
			damage = 15
			knockback_amount = 120
			paths = 3
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1 - player.spell_cooldown)
	attackTimer.wait_time = attack_speed
	self.scale = Vector2(attack_size, attack_size)

func _physics_process(delta: float) -> void:
	# if there is a target to attack move towards it
	if not collision.disabled:
		position += angle * speed * delta
	# if not the javelin floats back to the player
	else:
		var player_angle: Vector2 = global_position.direction_to(reset_pos)
		var distance_diff: Vector2 = global_position - player.global_position
		var return_speed: int = 20
		# javelin returns faster if far away to keep closer to player
		if abs(distance_diff.x) > 500 or abs(distance_diff.y) > 500:
			return_speed = 100
		position += player_angle * return_speed * delta
		rotation = global_position.direction_to(player.global_position).angle() * deg_to_rad(135)
		
## Add the targets to attack
func add_paths() -> void:
	# play attack sound
	sound_attack.play()
	# remove from hit_once hurt box already attacked list so it can attack more than once
	emit_signal("remove_from_list", self)
	# create new list of targets
	target_list.clear()
	var counter: int = 0
	# get as many targets as there are paths
	while counter < paths:
		# get a random target
		var new_path: Vector2 = player.get_random_target()
		target_list.append(new_path)
		counter += 1
	enable_attack()
	# get the next target
	target = target_list.pop_back()
	process_path()
	
## Find the target's angle and smoothly rotate towards it
func process_path() -> void:
	angle = global_position.direction_to(target)
	changeDirectionTimer.start()
	var tween: Tween = create_tween()
	var new_rotation_degrees: float = angle.angle() + deg_to_rad(135)
	tween.tween_property(self, "rotation", new_rotation_degrees, 0.25).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	
## Enables or disables the javelin to attack and sets up the appropriate animation
func enable_attack(enabled: bool = true) -> void:
	# enable or disable javelin
	collision.call_deferred("set", "disabled", not enabled)
	# set correct sprite
	if enabled:
		sprite.texture = spr_jav_attack
	else: 
		sprite.texture = spr_jav_reg
	
## When ready to attack, add targets to attack then attack
func _on_attack_timer_timeout() -> void:
	add_paths()

## Attack in different directions until all targets are attacked
func _on_change_direction_timeout() -> void:
	# checks if targets are available
	# sets new target and attacks if possible
	if not target_list.is_empty():
		# removes a target to attack
		target = target_list.pop_back()
		process_path()
		sound_attack.play()
		# makes sure that it can hit enemies again even if they have hit once hurt boxes
		emit_signal("remove_from_list", self)
	# if done, reset and disable the javelins
	else:
		changeDirectionTimer.stop()
		attackTimer.start()
		enable_attack(false)

## Sets up a reset position to move towards during cooldown 
## pos 50 px away from player in rand direction
func _on_reset_pos_timer_timeout() -> void:
	var choose_direction: int = randi() % 4
	reset_pos = player.global_position
	match choose_direction:
		0: # right
			reset_pos.x += 50
		1: # left
			reset_pos.x -= 50
		2: # up
			reset_pos.y -= 50
		3: # down
			reset_pos.y += 50
