extends TileMapLayer

@onready var parent_layer: TileMapLayer = get_parent()
@onready var static_collision_body: StaticBody2D = $StaticBody2D
@onready var hurt_area: Area2D = $HurtArea
@onready var hurt_disable_timer: Timer = $HurtDisableTimer
@onready var cell_coordinates: Array[Vector2i] = get_used_cells()


@export var hp = 100

func _ready():
	create_combined_collision_polygon()
	# turn off collisions on parent
	parent_layer.collision_enabled = false


func create_combined_collision_polygon() -> void:
	var cell_polygons = []
	for cell in cell_coordinates:
		# get cell's collision polygon points
		var new_polygon_points: PackedVector2Array = get_cell_collision_polygon(cell)
		# create new collision and hurt polygons
		var new_collision_polygon = CollisionPolygon2D.new()
		var new_hurt_polygon = CollisionPolygon2D.new()
		# set the hurt and collision polygon's polygon
		new_collision_polygon.polygon = new_polygon_points
		new_hurt_polygon.polygon = new_polygon_points
		# add collision polygon as a child of the static body and hurt polygon as a child of the hurt area
		static_collision_body.add_child(new_collision_polygon)
		hurt_area.add_child(new_hurt_polygon)


func get_cell_collision_polygon(cell: Vector2i) -> PackedVector2Array:
	# get tile's data
	var tile_data: TileData = parent_layer.get_cell_tile_data(cell)
	var tile_size = parent_layer.tile_set.tile_size[0]
	# get tile's collision polygon
	var local_poly: PackedVector2Array = tile_data.get_collision_polygon_points(0, 0)
	
	# find adjusted coordinates, multiply by tile size and offset by half the tile size to account for centered position
	# tilesize must be even
	var coordinate_adjustment = Vector2i(cell.x * tile_size + (tile_size >> 1), cell.y * tile_size + (tile_size >> 1))
	
	# apply the translation to every point in the polygon
	var translated_polygon = PackedVector2Array()
	for point in local_poly:
		translated_polygon.append(Vector2(Vector2i(point) + coordinate_adjustment))
	
	return translated_polygon


func _on_hurt_area_area_entered(area: Area2D) -> void:
	# checks attacks
	if area.is_in_group("attack"):
		# if the attack does damage
		if not area.get("damage") == null:
			# disables the hurtbox of the victim
			hurt_area.call_deferred("set", "disabled", true)
			# activates the cooldown timer, 
			# which will reactive the hurtbox once done
			hurt_disable_timer.start()
			# collect hurt infomormation from damaging party
			take_damage(area.damage)

# Stop disabling hurtbox on timeout
func _on_hurt_disable_timer_timeout() -> void:
	hurt_area.call_deferred("set", "disabled", false)
	
func take_damage(damage: int) -> void:
	hp -= damage
	print("Hurt Group hit for %d damage. HP left: %d" % [damage, hp])
	if hp <= 0:
		destroy_group()

func destroy_group() -> void:
	print("Hurt Group destroyed")

	## Turn off collisions

	# stop disable timer on hurt area to prevent it from re-enabling the hurt polygon
	hurt_disable_timer.stop()
	# disable all collision polygons in hur area
	for child in hurt_area.get_children():
		child.set_deferred("disabled", true)
	# disable hurtarea
	hurt_area.set_deferred("disabled", true)
	# disable all collision polygons in collision body
	for child in static_collision_body.get_children():
		child.set_deferred("disabled", true)
	# disable collision body
	static_collision_body.set_deferred("disabled", true)

	
	# switch the sprite for every item in the group and show below everything but the floor
	for cell in cell_coordinates:
		parent_layer.set_cell(cell, parent_layer.tile_set.get_source_id(0), Vector2i(12, 3))
