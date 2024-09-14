extends Area2D

class_name Door

@export var proximity_radius: float = 50.0
@export var allowed_groups: Array[StringName] = [&"player"]
@export var is_open: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func setup_proximity_area():
	var shape = CircleShape2D.new()
	shape.radius = proximity_radius
	$ProximityArea/CollisionShape2D.shape = shape

func connect_signals():
	$ProximityArea.body_entered.connect(_on_body_entered)
	$ProximityArea.body_exited.connect(_on_body_exited)

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
		

func close():
	if is_open:
		is_open = false