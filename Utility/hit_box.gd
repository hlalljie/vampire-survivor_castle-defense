extends Area2D

@export var damage: int = 1
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var disableTimer: Timer = $DisableHitBoxTimer

## Disables hitbox of the attacker temporarily when called
func temp_disable() -> void:
	# disables hitbox collisions
	collision.call_deferred("set", "disabled", true)
	# starts a time that re-enables after complete
	disableTimer.start()


## Re-enables the hitbox once the diable timer is complete
func _on_disable_hit_box_timer_timeout() -> void:
	collision.call_deferred("set", "disabled", false)
