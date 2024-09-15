extends Door

class_name Gate

@export var open_distance: Vector2 = Vector2(0.0, 70.0)
@export var hp: int = 500
@export var damaged_by: Array[StringName] = [&"enemy"]

@onready var hurt_box = $HurtBox
@onready var destroyed_sprite = $DestroyedSprite
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


func _on_hurt_box_hurt(damage: int, _angle: Vector2, _knockback: int) -> void:
	hp -= damage
	print("Gate hit for %d damage. HP left: %d" % [damage, hp])
	if hp <= 0:
		destroy_gate()

func destroy_gate() -> void:
	print("Gate destroyed!")
	door_sprite.hide()
	destroyed_sprite.show()
	door_collision.set_deferred("disabled", true)
	hurt_box.set_deferred("disabled", true)
