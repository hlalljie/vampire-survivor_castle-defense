extends Node2D

@export var spawns: Array[SpawnInfo] = []
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

# keeps track of the current time
var time: int = 0

signal change_time(time: int)

func _ready() -> void:
	connect("change_time", Callable(player, "change_time"))

## Counts time and spawns enemies based on time
func _on_timer_timeout() -> void:
	# counts time
	time += 1
	
	# list of enemy spawns (waves/groups of enemies to spawn)
	var enemy_spawns: Array[SpawnInfo] = spawns
	# loop through all spawns
	for e in enemy_spawns:
		# if the spawner is still spawning enemies then continue
		if time >= e.time_start and time <= e.time_end:
			# if it is not time to spawn an enemy increase the timer
			if e.spawn_delay_counter < e.enemy_spawn_delay:
				e.spawn_delay_counter += 1
			# if it is time to spawn an enemy do it
			else:
				# reset the spawn counter
				e.spawn_delay_counter = 0
				# no need to load as arrays automatically load
				var new_enemy: Resource = e.enemy
				# spawn enemies
				for i in range(e.enemy_number):
					# instantiate new enemy
					var enemy_spawn: CharacterBody2D = new_enemy.instantiate()
					# get a random position to spawn
					enemy_spawn.global_position = get_random_position()
					# add the enemy to the scene (via the spawner)
					add_child(enemy_spawn)
	emit_signal("change_time", time)
					
## Gets a random position outside of the viewport (in a range)
## @return Vector2 A random position outside of the viewport
func get_random_position() -> Vector2:
	# random range outside of the viewport
	var random_range: float = randf_range(1.1, 1.4)
	# a zone right outisde of the viewport
	var spawn_zone: Vector2 = get_viewport_rect().size * random_range
	
	# find the edges of the defined spawn zone for easily finding corners
	var left: float = player.global_position.x - (spawn_zone.x/2)
	var right: float = player.global_position.x + (spawn_zone.x/2)
	var top: float = player.global_position.y - (spawn_zone.y/2)
	var bottom: float = player.global_position.y + (spawn_zone.y/2)
	
	# find the corners of spawn zone for randomizing between them for spawn
	var top_left: Vector2 = Vector2(left, top)
	var bottom_left: Vector2 = Vector2(left, bottom)
	var bottom_right: Vector2 = Vector2(right, bottom)
	var top_right: Vector2 = Vector2(right, top)
	
	# intialize the 2 corners to spawn between
	var spawn_corner1: Vector2 = Vector2(0.0, 0.0)
	var spawn_corner2: Vector2 = Vector2(0.0, 0.0)
	
	# pick a random side
	var spawn_side: String = ["top", "bottom", "left", "right"].pick_random()
	# set the 2 corners based on the side
	match spawn_side:
		"top":
			spawn_corner1 = top_left
			spawn_corner2 = top_right
		"bottom":
			spawn_corner1 = bottom_left
			spawn_corner2 = bottom_right
		"right":
			spawn_corner1 = bottom_right
			spawn_corner2 = top_right
		"left":
			spawn_corner1 = top_left
			spawn_corner2 = bottom_left
	
	# pick a random point between the two corners
	var spawn_x: float = randf_range(spawn_corner1.x, spawn_corner2.x)
	var spawn_y: float = randf_range(spawn_corner1.y, spawn_corner2.y)
	
	# return the random spawn location
	return Vector2(spawn_x, spawn_y)
	
				
