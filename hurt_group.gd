extends TileMapLayer

@onready var parent_layer: TileMapLayer = get_parent()
@onready var hurt_collision_shape: CollisionShape2D = $HurtBox/CollisionShape2D

func _ready():
	create_combined_collision_polygon()

func create_combined_collision_polygon() -> void:
	# create an empty polygon to merge with all parent polygons
	var new_collision_polygon: PackedVector2Array = PackedVector2Array()

	for cell in get_used_cells():
		
		# get tile's data
		var parent_tile_data: TileData = parent_layer.get_cell_tile_data(cell)
		# get tile's collision polygon
		var parent_local_poly: PackedVector2Array = parent_tile_data.get_collision_polygon_points(0, 0)
		# get cell's global position
		var cell_position: Vector2i = Vector2i(cell.x, cell.y)

		# apply coordinates to parent tile data's collision polygon
		var transformed_poly: PackedVector2Array = apply_coordinates_to_polygon(parent_local_poly, cell_position)
		print(transformed_poly)
		# merge the transformed polygon with the new collision polygon
		new_collision_polygon = Geometry2D.merge_polygons(new_collision_polygon, transformed_poly)[0]
		
		# remove parent tile data's collision polygon
		# parent_tile_data.remove_collision_polygon(0, 0)

	#set hurt collision polygon to our new combined collision polygon
	var hurt_collision_polygon: ConvexPolygonShape2D = ConvexPolygonShape2D.new()
	hurt_collision_polygon.set_points(new_collision_polygon)
	hurt_collision_shape.set_shape(hurt_collision_polygon)

func apply_coordinates_to_polygon(polygon: PackedVector2Array, cell_position: Vector2i) -> PackedVector2Array:
	var coordinate_adjustment = Vector2i(cell_position.x * 32 + 16, cell_position.y * 32 + 16)
	var transformed_polygon = PackedVector2Array()
	
	for point in polygon:
		transformed_polygon.append(point + Vector2(coordinate_adjustment))
	
	return transformed_polygon


func _on_hurt_box_hurt(damage: int, angle: Vector2, knockback: int) -> void:
	print("hit damage: %d, angle: %s, knockback: %d" % [damage, angle, knockback])
