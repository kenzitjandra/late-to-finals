extends StaticBody2D

var opened := false


func _ready() -> void:
	close()


func open() -> void:
	if opened:
		return

	opened = true
	_set_gate_enabled(false)


func close() -> void:
	opened = false
	_set_gate_enabled(true)


func _set_gate_enabled(enabled: bool) -> void:
	var collision_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	var visual := get_node_or_null("Visual") as Polygon2D
	if collision_shape:
		collision_shape.disabled = not enabled
	if visual:
		visual.visible = enabled
