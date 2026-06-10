extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: Polygon2D = $Visual

var opened := false


func open() -> void:
	if opened:
		return

	opened = true
	collision_shape.disabled = true
	visual.visible = false
