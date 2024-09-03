extends Area2D


# global stats
var level: int = 1
var hp: int = 2 # penetration through enemies
var speed: int = 100
var damage: int = 5
var knockback_amount: int = 100
var attack_size: float = 1.0

# intialize firing vars
var target: Vector2 = Vector2(0.0, 0.0)
var angle: Vector2 = Vector2(0.0, 0.0)

@onready var player = get_tree().get_first_node_in_group("player")

signal remove_from_list(object: Object)

func _ready() -> void:
	# get angle to target
	angle = global_position.direction_to(target)
	# set rotation to the adjusted angle based on the sprite angle
	rotation = angle.angle() + deg_to_rad(135)
	# set level stats
	match level:
		1:
			hp= 2
			speed= 100
			damage= 5
			knockback_amount= 100
			attack_size = 1.0
	# set a enlarging amount on spawn
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1) * attack_size, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func _physics_process(delta: float) -> void:
	# move the object in the right direction
	position += angle*speed*delta
	
## When the enemy is hit reduce the projectile's hp and despawn if needed
func enemy_hit(charge: int = 1):
	# reduce projectile hp
	hp -= charge
	# despawn if necessary
	if hp <= 0:
		# remove from hurtbox list
		emit_signal("remove_from_list", self)
		queue_free()

## Delete projectile after some time is passed (and is offscreen)
func _on_timer_timeout() -> void:
	# remove from hurtbox list
	emit_signal("remove_from_list", self)
	queue_free()
