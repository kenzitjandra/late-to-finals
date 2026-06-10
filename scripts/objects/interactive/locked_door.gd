extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: Polygon2D = $Visual
@onready var status_label: Label = $StatusLabel

var opened := false


func _ready() -> void:
	if opened:
		_apply_open_state()
	else:
		_apply_locked_state()


func open() -> void:
	if opened:
		return

	opened = true
	_apply_open_state()
	print("LockedDoor opened.")


func close() -> void:
	if not opened:
		return

	opened = false
	_apply_locked_state()
	print("LockedDoor closed.")


func is_open() -> bool:
	return opened


func _apply_open_state() -> void:
	if collision_shape != null:
		collision_shape.disabled = true

	if visual != null:
		visual.visible = false

	if status_label != null:
		status_label.text = "Door Status: Open"


func _apply_locked_state() -> void:
	if collision_shape != null:
		collision_shape.disabled = false

	if visual != null:
		visual.visible = true

	if status_label != null:
		status_label.text = "Door Status: Locked"