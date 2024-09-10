extends Resource

## Contains the spawn info for a given spawn wave/setup
class_name SpawnInfo

# start time for the spawn
@export var time_start: int
# end time for the spawn
@export var time_end: int
# the resource for the spawn (add resource in editor)
@export var enemy: Resource
# number of enemies to spawn every cycle
@export var enemy_number: int
# how long between spaawn cycles in seconds
@export var enemy_spawn_delay: int
@export var disabled: bool = false
# current counter for spawn
var spawn_delay_counter: int = 0
