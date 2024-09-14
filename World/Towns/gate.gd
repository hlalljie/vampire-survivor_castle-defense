extends Door

class_name Gate

@export var open_distance: Vector2 = Vector2(0.0, 70.0)

@onready var start_position = door_sprite.position
@onready var end_position = start_position + open_distance

func _animate_open() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(door_sprite, "position", end_position, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func _animate_close() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(door_sprite, "position", start_position, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
