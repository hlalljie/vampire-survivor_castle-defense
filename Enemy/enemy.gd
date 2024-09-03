extends CharacterBody2D

# global variables
@export var movement_speed: float = 20
@export var hp: int = 10

# imported local variables (from node)
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer

# imported external variables (from other nodes)
@onready var player: Node = get_tree().get_first_node_in_group("player")

# runs once at the beginning
func _ready() -> void:
	# start animation
	anim.play("walk")


func _physics_process(delta: float) -> void:
	# Get the direction(unit vector) of the the enemy position towards the player position
	var direction: Vector2 = global_position.direction_to(player.global_position)
	# face enemy sprite in correct direction
	if direction.x > 0:
		sprite.flip_h = true
	elif direction.x < 0:
		sprite.flip_h = false

	# set velocity
	velocity = direction * movement_speed
	# move and set to slide on colllision
	move_and_slide()


func _on_hurt_box_hurt(damage: int) -> void:
	# lowers hp based on damage recieved
	hp -= damage
	print("Enemy hit %d for damage. Enemy HP now: %d" %[damage, hp])
	# if enemy is killed delete them from the scene
	if hp <= 0:
		print("Enemy killed")
		# deletes the enemy from the scene
		queue_free()
