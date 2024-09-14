extends StaticBody2D

class_name Door

@export var allowed_groups: Array[StringName] = [&"player"]
@export var is_open: bool = false

@onready var sprite_controller: Control = $SpriteController
@onready var door_sprite: Sprite2D = $SpriteController/Sprite2D
@onready var door_collision: CollisionShape2D = $CollisionShape2D
@onready var proximity_area: Area2D = $ProximityDetector
@onready var proximity_collision: CollisionShape2D = $ProximityDetector/CollisionShape2D

@onready var initial_color = door_sprite.modulate

func _ready():
	connect_signals()

func connect_signals():
	proximity_area.body_entered.connect(_on_body_entered)
	proximity_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if is_body_in_allowed(body):
		open()
		return

func _on_body_exited(body):
	if is_body_in_allowed(body):
		close()
		return

func is_body_in_allowed(body):
	for group in allowed_groups:
		if body.is_in_group(group):
			return true
	return false

func open():
	if not is_open:
		is_open = true
		door_collision.set_deferred("disabled", true)
		_animate_open()


func close():
	if is_open:
		is_open = false
		door_collision.set_deferred("disabled", false)
		_animate_close()

func _animate_open() -> void:
	var transparent: Color = initial_color
	transparent.a = 0
	var tween: Tween = create_tween()
	tween.tween_property(door_sprite, "modulate", transparent, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func _animate_close() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(door_sprite, "modulate", initial_color, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
