extends Sprite2D

## Play the explosion animation
func _ready() -> void:
	$AnimationPlayer.play("explode")

## Delete the animation once finished
func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
