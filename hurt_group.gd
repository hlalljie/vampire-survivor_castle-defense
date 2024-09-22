extends TileMapLayer

@onready var parent_layer: TileMapLayer = get_parent()
@onready var hurt_collision_polygon: CollisionPolygon2D = $HurtPolygon/CollisionPolygon2D
@onready var static_collision_body: StaticBody2D = $StaticBody2D
@onready var static_collision_polygon: CollisionPolygon2D = $StaticBody2D/CollisionPolygon2D

@export var hp = 100

func _ready():
	create_combined_collision_polygon()
	# turn off collisions on parent
	parent_layer.collision_enabled = false
	#visible = false

func create_combined_collision_polygon() -> void:
	# create an empty polygon to merge with all parent polygons
	var new_collision_polygon_points: PackedVector2Array = PackedVector2Array()

	for cell in get_used_cells():
		
		# apply coordinates to parent tile data's collision polygon
		var parent_poly: PackedVector2Array = get_cell_collision_polygon(cell)

		# merge the transformed polygon with the new collision polygon
		new_collision_polygon_points = Geometry2D.merge_polygons(new_collision_polygon_points, parent_poly)[0]

	print(new_collision_polygon_points)
	# set collision polygons for hurtgroup to our new combined collision polygon
	hurt_collision_polygon.set_polygon(new_collision_polygon_points)
	static_collision_polygon.set_polygon(new_collision_polygon_points)


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
	
	# remove parent tile data's collision polygon
	# tile_data.remove_collision_polygon(0, 0)
	
	return translated_polygon


func _on_hurt_polygon_hurt(damage: int, _angle: Vector2, _knockback: int) -> void:
	hp -= damage
	print("Hurt Group hit for %d damage. HP left: %d" % [damage, hp])
	if hp <= 0:
		destroy_group()

func destroy_group() -> void:
	print("Hurt Group destroyed")
