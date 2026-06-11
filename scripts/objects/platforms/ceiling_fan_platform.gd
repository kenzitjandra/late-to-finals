extends StaticBody2D

@export var collapse_delay: float = 0.6
@export var respawn_delay: float = 2.5

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: CanvasItem = $Sprite2D
@onready var detector: Area2D = $PlayerDetector

var is_ready := true
var is_hidden := false


func _ready() -> void:
	add_to_group("temporary_platform")
	detector.body_entered.connect(_on_detector_body_entered)


func _on_detector_body_entered(body: Node2D) -> void:
	if not is_ready or is_hidden or not body.is_in_group("player"):
		return

	_start_collapse_sequence()


func _start_collapse_sequence() -> void:
	is_ready = false
	await get_tree().create_timer(collapse_delay).timeout
	_hide_platform()
	await get_tree().create_timer(respawn_delay).timeout
	_show_platform()


func _hide_platform() -> void:
	is_hidden = true
	collision_shape.set_deferred("disabled", true)
	visual.visible = false
	if name == "Functional_CeilingFanPlatform" and get_parent() is CanvasItem:
		get_parent().hide()


func _show_platform() -> void:
	collision_shape.set_deferred("disabled", false)
	visual.visible = true
	if name == "Functional_CeilingFanPlatform" and get_parent() is CanvasItem:
		get_parent().show()
	is_hidden = false
	is_ready = true
