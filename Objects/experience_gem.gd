extends Area2D

@export var experience: int = 1

var spr_green: Resource = preload("res://Textures/Items/Gems/Gem_green.png")
var spr_blue: Resource = preload("res://Textures/Items/Gems/Gem_blue.png")
var spr_red: Resource = preload("res://Textures/Items/Gems/Gem_red.png")

var target: CharacterBody2D = null
var speed: float = -.4

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sound_collected: AudioStreamPlayer = $sound_collected

func _ready():
	set_experience_sprite()
	
## Sets the correct sprite based on the experience amount
func set_experience_sprite() -> void:
	# green already by default
	if experience < 5:
		return
	# blue 5 or greater
	if experience < 25:
		sprite.texture = spr_blue
	# red 25 or greater
	else:
		sprite.texture = spr_red
		
func _physics_process(delta: float) -> void:
	# move towards target if there is a target (will be player)
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		# accelerates at a rate of 2
		speed += 2 * delta
		
func collect() -> int:
	sound_collected.play()
	# don't queue free yet as sound is still playing
	collision.call_deferred("set", "disabled", true)
	sprite.visible = false
	return experience
	
func _on_sound_collected_finished() -> void:
	queue_free()
