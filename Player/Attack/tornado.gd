extends Area2D

# Regular Attack Variables
var level: int = 1
var hp: int = 999
var speed: float = 100.0
var damage: int = 5
var attack_size: float = 1.0
var knockback_amount: int = 100

# expanded attack variables
var last_movement: Vector2 = Vector2.ZERO
var angle: Vector2 = Vector2.ZERO
var angle_less: Vector2 = Vector2.ZERO
var angle_more: Vector2 = Vector2.ZERO

signal remove_from_list(object: Object)

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	match level:
		1:
			hp = 9999
			speed = 100.0
			damage = 5
			attack_size = 1.0 * (1 + player.spell_size)
			knockback_amount = 100
		# additional tornado (so no changes here
		2:
			hp = 9999
			speed = 100.0
			damage = 5
			attack_size = 1.0 * (1 + player.spell_size)
			knockback_amount = 100
		# reduces cooldown (so no changes here
		3:
			hp = 9999
			speed = 100.0
			damage = 5
			attack_size = 1.0 * (1 + player.spell_size)
			knockback_amount = 100
		# increase knockback
		4:
			hp = 9999
			speed = 100.0
			damage = 5
			attack_size = 1.0 * (1 + player.spell_size)
			knockback_amount = 125
		 
	# bounce between two points in space to give a similar to sine wave patters (sharper than sine)
	var move_to_less = Vector2.ZERO
	var move_to_more = Vector2.ZERO
	# Send an attack in the direction of the last movement (will also have a "wave" to it)
	match last_movement:
		# get two random bounce between points in on the axis of the attack based on movement direction
		Vector2.UP, Vector2.DOWN:
			move_to_less = global_position + Vector2(randf_range(-1, -0.25), last_movement.y) * 500
			move_to_more = global_position + Vector2(randf_range(0.25, 1), last_movement.y) * 500
		Vector2.LEFT, Vector2.RIGHT:
			move_to_less = global_position + Vector2(last_movement.x, randf_range(-1, -0.25)) * 500
			move_to_more = global_position + Vector2(last_movement.x, randf_range(0.25, 1)) * 500
		Vector2(1,1), Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1):
			move_to_less = global_position + Vector2(last_movement.x, last_movement.y * randf_range(0, 0.75)) * 500
			move_to_more = global_position + Vector2(last_movement.x * randf_range(0, 0.75), last_movement.y) * 500
	
	# set movement angles towards the determined direction
	angle_less = global_position.direction_to(move_to_less)
	angle_more = global_position.direction_to(move_to_more)
	
	# create a tween to scale up the attack for the first couple seconds
	var initial_tween: Tween = create_tween().set_parallel()
	initial_tween.tween_property(self, "scale", Vector2(1, 1) * attack_size, 3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	# speed up the attack over time
	var final_speed: float = speed
	speed = speed/5.0
	initial_tween.tween_property(self, "speed", final_speed, 6).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	initial_tween.play()
	
	# tween between the two determined angles to give a wave (back and forth) effect
	var tween: Tween = create_tween()
	# randomize the start arc
	var set_angle: int = randi_range(0, 1)
	if set_angle == 1:
		angle = angle_less
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
		tween.set_loops()
	else:
		angle = angle_more
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
		tween.set_loops()
	tween.play()
		
	
func _physics_process(delta: float) -> void:
	position += angle*speed*delta

func _on_timer_timeout() -> void:
	emit_signal("remove_from_list")
	queue_free()
